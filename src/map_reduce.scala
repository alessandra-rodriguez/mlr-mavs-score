import org.apache.spark.sql._
import org.apache.spark.sql.functions._
import org.apache.spark.sql.types._
import breeze.linalg.{DenseMatrix, inv}

val df = spark.read
  .option("header", "true")
  .option("inferSchema", "true")
  .csv("/FileStore/tables/mlr_mavs.csv")

val df_indexed = df.rdd.zipWithIndex
val cols = df.columns

val y = cols(0)
val x = cols.drop(1)

val y_rdd = df_indexed.map {case (row, row_index) =>
  (row_index, row.getAs[Any](y).asInstanceOf[Integer])
}

val y_df = y_rdd.toDF("row_num", "value")
y_df.show(false)

val x_rdd = df_indexed.flatMap {case (row, row_index) =>
  val intercept = Seq(("1", 0)) ++ other_cols.zipWithIndex.map {case (col_name, col_index) =>
    val value = row.getAs[Any](col_name).toString
    (value, col_index + 1)
  }
  intercept.map {case (value, col_index) =>
    (row_index, col_index, value)
  }
}

val x_df = x_rdd.toDF("row", "col", "value")
x_df.show(false)

y_df.write
  .mode("overwrite")
  .csv("/FileStore/tables/y_mavs_mlr")

x_df.write
  .mode("overwrite")
  .csv("/FileStore/tables/x_mavs_mlr")

val x = sc.textFile("/FileStore/tables/x_mavs_mlr")
  .map(line => {
    val l = line.split(",")
    (l(0).toInt, (l(1).toInt, l(2).toDouble))})

val y = sc.textFile("/FileStore/tables/y_mavs_mlr")
  .map(line => {
    val l = line.split(",")
    (l(0).toInt, l(1).toDouble)})

val xT = sc.textFile("/FileStore/tables/x_mavs_mlr")
  .map(line => {
    val l = line.split(",")
    (l(1).toInt, l(0).toInt, l(2).toDouble)})
  .map{case (r, c, v) =>
  (c, (r, v))}

val xxT = x.join(xT)
  .map{case (t, ((r1, v1), (r2, v2))) => {
    val v3 = v1 * v2
    ((r1, r2), v3)}}
  .reduceByKey(_+_)
  .sortBy {case ((r, c), v) => {
    (r, c)}}
  .collect()

val rows = xxT
  .map{case ((r, c), v) => r}
val cols = xxT
  .map{case ((r, c), v) => c}
val values = xxT
  .map {case((r, c), v) => v}

val maxRow = rows.max + 1
val maxCol = cols.max + 1

val breezeM = new DenseMatrix[Double](maxRow, maxCol, values.toArray)
val xxT_inv = inv(breezeM)

val xxt_inv_matrix = for {
  r <- 0 until maxRow
  c <- 0 until maxCol
} yield (c.toInt, (r.toInt, xxT_inv(r, c).toDouble))

val xTx_inv = sc.parallelize(xxt_inv_matrix)

val xTy = xT.join(y)
  .map{case (key, ((xT_index, xT_value), y_value)) => {
    ((key, xT_index), xT_value*y_value)
  }}
  .map(element => (element._1._2, element._2))
  .reduceByKey(_+_)

val result = xTx_inv.join(xTy)
  .map{case (key, ((xTx_inv_index, xTx_inv_value), xTy_value)) => {
    ((key, xTx_inv_index), xTx_inv_value*xTy_value)
  }}
  .map(element => (element._1._2, element._2))
  .reduceByKey(_+_)
  .collect
  .foreach(println)
