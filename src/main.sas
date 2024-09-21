proc corr data=WORK.IMPORT noprob;
	var points turnovers rebounds doncic_min percentage;

proc reg data=WORK.IMPORT;
	model points = turnovers rebounds doncic_min percentage / vif influence;
	output out=mlrout predicted=yhat residual=e;

proc sgplot data=mlrout;
    scatter x=yhat y=e / markerattrs=(symbol=circlefilled);
    xaxis label='Predicted Points';
    yaxis label='e(Y|turnovers,rebounds,doncic_min,percentage,stddoncic_min_squared,stdrebounds_squared)';
run;

proc means data=mlrout noprint;
    var yhat;
    output out=median_x median=median_x;
run;

data mlrout_modlev;
    set mlrout;
    if yhat > 115 then group = 1;
    else group = 2;
run; 

proc sort data = mlrout_modlev;
	by group;
	
proc univariate data = mlrout_modlev noprint;
	by group;
	var e;
	output out=mout median=mede;
	
proc print data=mout;
	var group mede;
	
data mtemp; merge mlrout_modlev mout;
	by group;
	d = abs(e-mede);
	
proc sort data = mtemp;
	by group;
	
proc ttest data = mtemp;
	class group;
	var d;

data cutoffs;
	tinvtres = tinv(0.99833333, 24); output;

proc univariate data=mlrout normal;
    var e;
    qqplot e;
    title "Normal Probability Plot of Residuals";
run;

data mlrout;
    set mlrout;
    obsnum + 1;
run;

proc sgplot data=mlrout;
    scatter x=obsnum y=e / markerattrs=(symbol=circlefilled);
    series x=obsnum y=e / lineattrs=(color=blue);
    title "Observation Number against Residuals";
    xaxis label="Observation Number";
    yaxis label="Residuals";
run;

proc rank normal=blom data=mlrout out=mlrout;
    var e;
    ranks enrm;
run;

proc corr data=mlrout;
    var e enrm;
    title "Correlation Analysis between Residuals and Normal Scores";
run;


data mlrinteractions; 
    set mlrout;
    turnovers_rebounds = turnovers * rebounds;
    turnovers_doncic = turnovers * doncic_min;
    turnovers_percent = turnovers * percentage;
    rebounds_doncic = rebounds * doncic_min;
    rebounds_percent = rebounds * percentage;
    doncic_percent = doncic_min * percentage;
run;

proc reg data=mlrinteractions;
    model turnovers_rebounds = turnovers rebounds doncic_min percentage;
    output out=mlrinteractions residual=eturnovers_rebounds;
run;

proc reg data=mlrinteractions;
    model turnovers_doncic = turnovers rebounds doncic_min percentage;
    output out=mlrinteractions residual=eturnovers_doncic;
run;

proc reg data=mlrinteractions;
    model turnovers_percent = turnovers rebounds doncic_min percentage;
    output out=mlrinteractions residual=eturnovers_percent;
run;

proc reg data=mlrinteractions;
    model rebounds_doncic = turnovers rebounds doncic_min percentage;
    output out=mlrinteractions residual=erebounds_doncic;
run;

proc reg data=mlrinteractions;
    model rebounds_percent = turnovers rebounds doncic_min percentage;
    output out=mlrinteractions residual=erebounds_percent;
run;

proc reg data=mlrinteractions;
    model doncic_percent = turnovers rebounds doncic_min percentage;
    output out=mlrinteractions residual=edoncic_percent;
run;

proc sgplot data=mlrinteractions;
    scatter x=eturnovers_percent y=e / markerattrs=(symbol=circlefilled);
    xaxis label='e(turnovers_percent|turnovers,rebounds,doncic_min,percentage)';
    yaxis label='e(Y|turnovers,rebounds,doncic_min,percentage)';
    title "";
run;

proc sgplot data=mlrinteractions;
    scatter x=eturnovers_rebounds y=e / markerattrs=(symbol=circlefilled);
    xaxis label='e(turnovers_rebounds|turnovers,rebounds,doncic_min,percentage)';
    yaxis label='e(Y|turnovers,rebounds,doncic_min,percentage)';
run;

proc sgplot data=mlrinteractions;
    scatter x=eturnovers_doncic y=e / markerattrs=(symbol=circlefilled);
    xaxis label='e(turnovers_doncic|turnovers,rebounds,doncic_min,percentage)';
    yaxis label='e(Y|turnovers,rebounds,doncic_min,percentage)';
run;

proc sgplot data=mlrinteractions;
    scatter x=erebounds_doncic y=e / markerattrs=(symbol=circlefilled);
    xaxis label='e(rebounds_doncic|turnovers,rebounds,doncic_min,percentage)';
    yaxis label='e(Y|turnovers,rebounds,doncic_min,percentage)';
run;

proc sgplot data=mlrinteractions;
    scatter x=erebounds_percent y=e / markerattrs=(symbol=circlefilled);
    xaxis label='e(rebounds_percent|turnovers,rebounds,doncic_min,percentage)';
    yaxis label='e(Y|turnovers,rebounds,doncic_min,percentage)';
run;

proc sgplot data=mlrinteractions;
    scatter x=edoncic_percent y=e / markerattrs=(symbol=circlefilled);
    xaxis label='e(doncic_percent|turnovers,rebounds,doncic_min,percentage)';
    yaxis label='e(Y|turnovers,rebounds,doncic_min,percentage)';
run;

data mlrout_std;
    set mlrinteractions;
    std_trn = turnovers;
    std_doncic = doncic_min;
    std_perc = percentage;
    std_rebs = rebounds;
run;

proc standard data=mlrout_std
    mean=0 std=1 out=mlrout_std;
    var std_trn std_doncic std_perc std_rebs;
run;

data mlrout_std;
    set mlrout_std;
    std_trn_perc = std_trn*std_perc;
    std_rebs_doncic = std_rebs*std_doncic;
    std_rebs_perc = std_rebs*std_perc;
run;

proc corr data=mlrout_std noprob;
	var turnovers rebounds doncic_min percentage turnovers_percent rebounds_doncic rebounds_percent;
run;

proc corr data=mlrout_std noprob;
	var turnovers rebounds doncic_min percentage std_trn_perc std_rebs_doncic std_rebs_perc;
run;

proc reg data=mlrout_std;
	model points = turnovers rebounds doncic_min percentage std_trn_perc std_rebs_doncic std_rebs_perc / selection=backward slstay=0.1;
run;

proc reg data=mlrout_std;
	model points = turnovers rebounds doncic_min percentage std_trn_perc std_rebs_doncic std_rebs_perc / selection=stepwise slstay=0.1 slentry=0.1;
run;

proc reg data=mlrout_std;
	model points = turnovers rebounds doncic_min percentage std_trn_perc std_rebs_doncic std_rebs_perc / selection = adjrsq cp aic sbc start=1 stop =1 best=2;
run;

proc reg data=mlrout_std;
	model points = turnovers rebounds doncic_min percentage std_trn_perc std_rebs_doncic std_rebs_perc / selection = adjrsq cp aic sbc start=2 stop =2 best=2;
run;

proc reg data=mlrout_std;
	model points = turnovers rebounds doncic_min percentage std_trn_perc std_rebs_doncic std_rebs_perc / selection = adjrsq cp aic sbc start=3 stop =3 best=2;
run;

proc reg data=mlrout_std;
	model points = turnovers rebounds doncic_min percentage std_trn_perc std_rebs_doncic std_rebs_perc / selection = adjrsq cp aic sbc start=4 stop =4 best=2;
run;

proc reg data=mlrout_std;
	model points = turnovers rebounds doncic_min percentage std_trn_perc std_rebs_doncic std_rebs_perc / selection = adjrsq cp aic sbc start=5 stop =5 best=2;
run;

proc reg data=mlrout_std;
	model points = turnovers rebounds doncic_min percentage std_trn_perc std_rebs_doncic std_rebs_perc / selection = adjrsq cp aic sbc start=6 stop =6 best=2;
run;

proc reg data=mlrout_std;
	model points = turnovers rebounds doncic_min percentage std_trn_perc std_rebs_doncic std_rebs_perc / selection = adjrsq cp aic sbc start=7 stop =7 best=1;
run;

proc reg data=mlrout_std;
	model points = turnovers rebounds percentage/ vif;
run;

proc reg data=mlrout_std;
	model points = turnovers rebounds percentage std_trn_perc/ vif;
run;

proc reg data=mlrout_std;
	model points = turnovers rebounds percentage std_trn_perc doncic_min/ vif influence;
	output out=fivea predicted=yhat_fivea residual=e_fivea;
run;

proc reg data=mlrout_std outest=model;
	model points = turnovers rebounds percentage std_trn_perc doncic_min std_rebs_doncic/ vif influence;
	output out=sixa predicted=yhat_sixa residual=e_sixa;
run;

proc reg data=mlrout_std;
	model points = turnovers rebounds percentage std_rebs_perc doncic_min std_rebs_doncic/ vif;
run;


proc sgplot data=fivea;
    scatter x=yhat_fivea y=e_fivea / markerattrs=(symbol=circlefilled);
    xaxis label='Predicted Points';
    yaxis label='e(Y|turnovers,rebounds,percentage,std_trn_perc,doncic_min)';
run;

proc means data=fivea noprint;
    var yhat_fivea;
    output out=median_x_fivea median=median_x_fivea;
run;

proc univariate data=fivea normal;
    var e_fivea;
    qqplot e_fivea;
    title "Normal Probability Plot of Residuals";
run;

data fivea;
    set fivea;
    obsnum + 1;
run;

proc sgplot data=fivea;
    scatter x=obsnum y=e_fivea / markerattrs=(symbol=circlefilled);
    series x=obsnum y=e_fivea / lineattrs=(color=blue);
    title "Observation Number against Residuals";
    xaxis label="Observation Number";
    yaxis label="Residuals";
run;


proc sgplot data=sixa;
    scatter x=yhat_sixa y=e_sixa / markerattrs=(symbol=circlefilled);
    xaxis label='Predicted Points';
    yaxis label='e(Y|turnovers,rebounds,percentage,std_trn_perc,doncic_min,std_rebs_doncic)';
run;

proc means data=sixa noprint;
    var yhat_sixa;
    output out=median_x_sixa median=median_x_sixa;
run;

proc univariate data=sixa normal;
    var e_sixa;
    qqplot e_sixa;
    title "Normal Probability Plot of Residuals";
run;

data sixa;
    set sixa;
    obsnum + 1;
run;

proc sgplot data=sixa;
    scatter x=obsnum y=e_sixa / markerattrs=(symbol=circlefilled);
    series x=obsnum y=e_sixa / lineattrs=(color=blue);
    title "Observation Number against Residuals";
    xaxis label="Observation Number";
    yaxis label="Residuals";
run;
