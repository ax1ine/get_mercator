unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, FileUtil, DateTimePicker,  Controls, Graphics,
  StdCtrls, ExtCtrls, ComCtrls, Dialogs, Spin, Buttons, LCLIntf, LCLTranslator,
  IniFiles, DateUtils, Process, Math;

type

  { Tfrmmain }

  Tfrmmain = class(TForm)
    btnCancel: TButton;
    btnDownloadMercator: TButton;
    btnDownloadMissing1: TLabel;
    btnInstallMOTU: TButton;
    btnOpenFolderMercator: TBitBtn;
    btnPythonPath: TButton;
    btnSavePass: TButton;
    btnUpgradeMOTU: TButton;
    cbService: TComboBox;
    chgMonth: TCheckGroup;
    chgParameters: TCheckGroup;
    chkScheduler: TCheckBox;
    dtp1: TDateTimePicker;
    dtp2: TDateTimePicker;
    dtpFinish: TDateTimePicker;
    dtpStart: TDateTimePicker;
    eUser: TEdit;
    ePass: TEdit;
    ePythonPath: TEdit;
    Label1: TLabel;
    btnDownloadMissing: TLabel;
    mPython: TMemo;
    rgGroupBy: TRadioGroup;
    seymin: TFloatSpinEdit;
    GroupBox1: TGroupBox;
    GroupBox14: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    lpass: TLabel;
    lusr: TLabel;
    mCMEMS: TMemo;
    mLog: TMemo;
    OD: TOpenDialog;
    PageControl1: TPageControl;
    rgLanguage: TRadioGroup;
    rgProduct: TRadioGroup;
    selev1: TFloatSpinEdit;
    selev2: TFloatSpinEdit;
    seymax: TFloatSpinEdit;
    sexmin: TFloatSpinEdit;
    sexmax: TFloatSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Timer1: TTimer;

    procedure btnCancelClick(Sender: TObject);
    procedure btnDownloadMissing1Click(Sender: TObject);
    procedure btnDownloadMissingClick(Sender: TObject);
    procedure btnUpgradeMOTUClick(Sender: TObject);
    procedure btnInstallMOTUClick(Sender: TObject);
    procedure btnOpenFolderMercatorClick(Sender: TObject);
    procedure btnPythonPathClick(Sender: TObject);
    procedure btnSavePassClick(Sender: TObject);
    procedure btnShowInstalledClick(Sender: TObject);
    procedure cbServiceChange(Sender: TObject);
    procedure chkSchedulerChange(Sender: TObject);
    procedure ePythonPathChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnDownloadMercatorClick(Sender: TObject);
    procedure rgLanguageClick(Sender: TObject);
    procedure rgProductClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);


  private
    procedure SelectParameters;
    procedure DownloadGlobalAnalysis(t_str0, t_str1, par_str, cmd0:string);
    procedure RunScript(cmd:string);
  public

  end;

resourcestring
  SJan = 'January';  SFeb = 'February'; SMar = 'March'; SApr = 'April';
  SMay = 'May'; SJun = 'Jun'; SJul = 'July'; SAug = 'August';
  SSep = 'September'; SOct ='October'; SNov = 'November'; SDec = 'December';
  SDateCannotPrecede = 'Date cannot preceed ';
  SDateCannotExceed = 'Date cannot exceed ';
  SSelectParameters = 'Please, select parameters';
  SSelectLevels = 'Please, select levels';
  SSelectTime = 'Please, select time';
  SSelectSteps = 'Please, select step';
  SNoPython = 'Python is not found';
  SProductDaily = 'Daily';
  SProductMonthly = 'Monthly';

  SParameter1  = 'Sea surface height';
  SParameter2  = 'Density ocean mixed layer thickness';
  SParameter3  = 'Salinity';
  SParameter4  = 'Sea ice eastward velocity';
  SParameter5  = 'Sea ice northward velocity';
  SParameter6  = 'Sea ice thickness';
  SParameter7  = 'Potential temperature';
  SParameter8  = 'Ice concentration';
  SParameter9  = 'Sea floor potential temperature';
  SParameter10 = 'Eastward velocity';
  SParameter11 = 'Northward velocity';

  SCMEMS = 'In order to download data one must have a CMEMS account. '+
           'If you do not have it, please, create one on the website '+
           'http://marine.copernicus.eu.';
  SPYTH =  'Data downloading is done by motuclient - a specail package '+
           'designed to work with CMEMS data. Motuclient integrates into '+
           'Python which can be downloaded from www.python.org';


var
  frmmain: Tfrmmain;
  GlobalPath, GlobalDataPath, GlobalSupportPath, IniFileName: string;
  motu, service, product: string;
  cancel_dl:boolean=false; // cancel downloading


implementation

{$R *.lfm}

{ Tfrmmain }

procedure Tfrmmain.FormShow(Sender: TObject);
Var
  Ini:TIniFile;
  k: integer;
begin
 mLog.Clear; //clean the log memo

  (* Define settings file, unique for every user*)
  IniFileName:=GetUserDir+'.climateshell';
  if not FileExists(IniFileName) then begin
    Ini:=TIniFile.Create(IniFileName);
    try
      Ini.WriteInteger('main', 'Language', 0);
    finally
     Ini.Free;
    end;
  end;

  Ini:=TIniFile.Create(IniFileName);
    try
     if Ini.ReadInteger( 'main', 'Language', 0)=0 then SetDefaultLang('en') else SetDefaultLang('ru');
     eUser.Text:=Ini.ReadString('dl_mercator', 'usr', '');
     ePass.Text:=Ini.ReadString('dl_mercator', 'pwd', '');

       {$IFDEF WINDOWS}
         ePythonPath.text:=Ini.ReadString('main', 'PythonPath', '');
         rgLanguage.ItemIndex:=Ini.ReadInteger ( 'main', 'Language', 0);
         btnPythonPath.Visible:=true;
      {$ENDIF}

      {$IFDEF UNIX}
         ePythonPath.text:=Ini.ReadString('main', 'PythonPath', 'python3');
         btnPythonPath.Visible:=false;
      {$ENDIF}
    finally
      Ini.Free;
    end;

  (* Define global path to the *.exe file *)
  GlobalPath:=ExtractFilePath(Application.ExeName);

  (* Define global delimiter *)
  DefaultFormatSettings.DecimalSeparator := '.';

    for k:=1 to 12 do begin
     case k of
      1:  chgMonth.Items.Add(SJan);
      2:  chgMonth.Items.Add(SFeb);
      3:  chgMonth.Items.Add(SMar);
      4:  chgMonth.Items.Add(SApr);
      5:  chgMonth.Items.Add(SMay);
      6:  chgMonth.Items.Add(SJun);
      7:  chgMonth.Items.Add(SJul);
      8:  chgMonth.Items.Add(SAug);
      9:  chgMonth.Items.Add(SSep);
      10: chgMonth.Items.Add(SOct);
      11: chgMonth.Items.Add(SNov);
      12: chgMonth.Items.Add(SDec);
     end;
     chgMonth.Checked[k-1]:=true;
    end;

    with rgProduct.Items do begin
      Clear;
       Add(SProductDaily);
       Add(SProductMonthly);
    end;
    rgProduct.ItemIndex:=0;

  mCMEMS.Clear;
  mCMEMS.Lines.Add(SCMEMS);

  mPython.Clear;
  mPython.Lines.Add(SPYTH);

  cbService.ItemIndex:=0;
  cbService.OnChange(self);
end;


procedure Tfrmmain.SelectParameters;
Var
  k:integer;
begin
  case cbService.ItemIndex of
   0: begin
    motu:='http://my.cmems-du.eu/motu-web/Motu';
    service:='GLOBAL_REANALYSIS_PHY_001_030-TDS';
    product:='global-reanalysis-phy-001-030';
      case rgProduct.ItemIndex of
        0: product:=product+'-daily';
        1: product:=product+'-monthly';
      end;
    dtp1.MinDate:=EncodeDate(1993, 01, 01);
    dtp2.MaxDate:=EncodeDate(2019, 12, 31);
   end;


   1: begin
    motu:='http://my.cmems-du.eu/motu-web/Motu';
    service:='GLOBAL_REANALYSIS_PHY_001_031-TDS';
    product:='global-reanalysis-phy-001-031-grepv2';
      case rgProduct.ItemIndex of
        0: product:=product+'-daily';
        1: product:=product+'-monthly';
      end;
    dtp1.MinDate:=EncodeDate(1993, 01, 01);
    dtp2.MaxDate:=EncodeDate(2019, 12, 31);
   end;

 //  http://nrtcmems.mercator-ocean.fr/motu-web/Motu -s GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS -d global-analysis-forecast-phy-001-024

// http://nrt.cmems-du.eu/motu-web/Motu -s GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS -d global-analysis-forecast-phy-001-024 -x -180 -X 179.9166717529297 -y -80 -Y 90 -t "2018-08-07 12:00:00" -T "2018-08-16 12:00:00" -z -1 -Z 0.4942 -v sea_water_potential_temperature -o <OUTPUT_DIRECTORY> -f CMEMS_Global_Ocean_10Days_Forecast.nc

   2: begin
    motu:='http://nrt.cmems-du.eu/motu-web/Motu';
   // motu:='http://nrtcmems.mercator-ocean.fr/motu-web/Motu';
    service:='GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS';
    product:='global-analysis-forecast-phy-001-024';
      case rgProduct.ItemIndex of
        0: begin
            product:=product;
            dtp2.MaxDate:=now+10;
           end;
        1: begin
            product:=product+'-monthly';
            dtp2.MaxDate:=now-45;
           end;
      end;
      dtp1.MinDate:=EncodeDate(2007, 01, 01);
   end;
  end;

  chgParameters.Items.Clear;
  if (cbService.ItemIndex=0) or (cbService.ItemIndex=2) then begin
    with chgParameters.Items do begin
     Add(SParameter1);
     Add(SParameter2);
     Add(SParameter3);
     Add(SParameter4);
     Add(SParameter5);
     Add(SParameter6);
     Add(SParameter7);
     Add(SParameter8);
     Add(SParameter9);
     Add(SParameter10);
     Add(SParameter11);
    end;
  end;

 { SParameter1  = 'Sea surface height';
  SParameter2  = 'Density ocean mixed layer thickness';
  SParameter3  = 'Salinity';
  SParameter4  = 'Sea ice eastward velocity';
  SParameter5  = 'Sea ice northward velocity';
  SParameter6  = 'Sea ice thickness';
  SParameter7  = 'Potential temperature';
  SParameter8  = 'Ice concentration';
  SParameter9  = 'Sea floor potential temperature';
  SParameter10 = 'Eastward velocity';
  SParameter11 = 'Northward velocity';}
  if (cbService.ItemIndex=1) then begin
    with chgParameters.Items do begin
     Add(SParameter1);
     Add(SParameter2);
     Add(SParameter3);
     Add(SParameter7);
     Add(SParameter10);
     Add(SParameter11);
    end;
  end;

  for k:=0 to chgParameters.Items.Count-1 do chgParameters.Checked[k]:=true;

  dtp1.Date:=dtp1.MinDate;
  dtp2.Date:=dtp2.MaxDate;
  dtp1.MaxDate:=dtp2.MaxDate;
  dtp2.MinDate:=dtp1.MinDate;
end;


procedure Tfrmmain.cbServiceChange(Sender: TObject);
begin
  SelectParameters;
end;

procedure Tfrmmain.rgProductClick(Sender: TObject);
begin
  SelectParameters;
end;



procedure Tfrmmain.btnDownloadMercatorClick(Sender: TObject);
Var
Ini: TIniFile;
k, cnt, dd: integer;
usr, pwd: string;
par_str, t_str0, t_str1, cmd0, mn_str, dd_str:string;
yy, yy0, mn0, dd0, yy1, mn1, dd1: word;
begin
 mLog.clear;
 Application.ProcessMessages;

 if not DirectoryExists(GlobalPath+'data'+PathDelim) then CreateDir(GlobalPath+'data'+PathDelim);
 if not DirectoryExists(GlobalPath+'data'+PathDelim+'mercator'+PathDelim) then
   CreateDir(GlobalPath+'data'+PathDelim+'mercator'+PathDelim);

 Ini := TIniFile.Create(IniFileName);
  try
   usr:=Ini.ReadString('dl_mercator', 'usr', '');
   pwd:=Ini.ReadString('dl_mercator', 'pwd', '');
  finally
   ini.Free;
  end;

  if (usr='') or (pwd='') then
   if MessageDlg('Update your Mercator username and password',
      mtWarning, [mbOk], 0)=mrOk then exit;

   cmd0:='-m motuclient '+
        '--user '+usr+' '+
        '--pwd '+pwd+' '+
        '--motu '+motu+' '+
        '--service-id '+service+' '+
        '--product-id '+product+' '+
        '--longitude-min '+sexmin.Text+' '+
        '--longitude-max '+sexmax.Text+' '+
        '--latitude-min '+seymin.Text+' '+
        '--latitude-max '+seymax.Text+' '+
        '--depth-min '+selev1.Text+' '+
        '--depth-max '+selev2.Text+' ';


 par_str:='';
 for k:=0 to chgParameters.Items.Count-1 do begin
  if ((cbService.ItemIndex=0) or (cbService.ItemIndex=2)) and
     (chgParameters.Checked[k]=true) then begin
   Case k of
    0: par_str:=par_str+' --variable zos';      // sea_surface_height_above_geoid
    1: par_str:=par_str+' --variable mlotst';   // ocean_mixed_layer_thickness_defined_by_sigma_theta
    2: par_str:=par_str+' --variable so';       // sea_water_salinity
    3: par_str:=par_str+' --variable usi';      // eastward_sea_ice_velocity
    4: par_str:=par_str+' --variable vsi';      // northward_sea_ice_velocity
    5: par_str:=par_str+' --variable sithick';  // sea_ice_thickness
    6: par_str:=par_str+' --variable thetao';   // sea_water_potential_temperature
    7: par_str:=par_str+' --variable siconc';   // sea_ice_area_fraction
    8: par_str:=par_str+' --variable bottomT';  // sea_water_potential_temperature_at_sea_floor
    9: par_str:=par_str+' --variable uo';       // eastward_sea_water_velocity
   10: par_str:=par_str+' --variable vo';       // northward_sea_water_velocity
   end;
  end;

  if (cbService.ItemIndex=1) and (chgParameters.Checked[k]=true) then begin
   Case k of
    0: par_str:=par_str+' --variable zos_cglo --variable zos_foam --variable zos_glor --variable zos_oras';      // sea_surface_height_above_geoid
    1: par_str:=par_str+' --variable mlotst_cglo --variable mlotst_foam --variable mlotst_glor --variable mlotst_oras';   // ocean_mixed_layer_thickness_defined_by_sigma_theta
    2: par_str:=par_str+' --variable so_cglo --variable so_foam --variable so_glor --variable so_oras';       // sea_water_salinity
    3: par_str:=par_str+' --variable thetao_cglo --variable thetao_foam --variable thetao_glor --variable thetao_oras';   // sea_water_potential_temperature
    4: par_str:=par_str+' --variable uo_cglo --variable uo_foam --variable uo_glor --variable uo_oras';       // eastward_sea_water_velocity
    5: par_str:=par_str+' --variable vo_cglo --variable vo_foam --variable vo_glor --variable vo_oras';       // northward_sea_water_velocity
   end;
  end;
 end;
 trim(par_str);

 if par_str='' then
  if MessageDlg(SSelectParameters, mtWarning, [mbOk], 0)=mrOk then exit;

 cnt:=DaysBetween(dtp2.Date, dtp1.Date)+1;

 btnDownloadMercator.Enabled:=false;
 try
 (* Daily *)
 if rgProduct.ItemIndex=0 then begin
  if rgGroupBy.ItemIndex=0 then begin
   for dd:=0 to cnt-1 do begin
     DecodeDate((IncDay(dtp1.Date, dd)), yy0, mn0, dd0);
      if mn0<10 then mn_str:='0'+inttostr(mn0) else mn_str:=inttostr(mn0);
      if dd0<10 then dd_str:='0'+inttostr(dd0) else dd_str:=inttostr(dd0);
      if (cbService.ItemIndex=0) or (cbService.ItemIndex=2) then
        t_str0:=inttostr(yy0)+'-'+mn_str+'-'+dd_str+' 12:00:00"';
      if (cbService.ItemIndex=1)then
        t_str0:=inttostr(yy0)+'-'+mn_str+'-'+dd_str+' 00:00:00"';

      if (chgMonth.Checked[mn0-1]=true) and
         (cancel_dl=false) then DownloadGlobalAnalysis(t_str0, t_str0, par_str, cmd0);
     if (chkScheduler.Checked=true) and (time>=dtpFinish.Time) then cancel_dl:=true;
   Application.ProcessMessages;
  end;
 end;

 if rgGroupBy.ItemIndex=2 then begin
     DecodeDate(dtp1.Date, yy0, mn0, dd0);
     DecodeDate(dtp2.Date, yy1, mn1, dd1);

     for yy:=yy0 to yy1 do begin
      if (cbService.ItemIndex=0) or (cbService.ItemIndex=2) then begin
        t_str0:=inttostr(yy)+'-01-01 12:00:00"';
        t_str1:=inttostr(yy)+'-12-31 12:00:00"';
      end;
      if (cbService.ItemIndex=1)then begin
        t_str0:=inttostr(yy)+'-01-01 00:00:00"';
        t_str1:=inttostr(yy)+'-12-31 00:00:00"';
      end;
     if (cancel_dl=false) then DownloadGlobalAnalysis(t_str0, t_str1, par_str, cmd0);
     if (chkScheduler.Checked=true) and (time>=dtpFinish.Time) then cancel_dl:=true;

    end;
 end;
end;


 (* Monthly *)
 if rgProduct.ItemIndex=1 then begin

  if rgGroupBy.ItemIndex=0 then begin
   For k:=0 to MonthsBetween(dtp1.Date, dtp2.Date) do begin
    DecodeDate((IncMonth(dtp1.Date, k)), yy0, mn0, dd0);
      if mn0<10 then mn_str:='0'+inttostr(mn0) else mn_str:=inttostr(mn0);
       t_str0:=inttostr(yy0)+'-'+mn_str;

       if (cbService.ItemIndex=0) or (cbService.ItemIndex=2) then begin
       if (mn0=1) or (mn0=3) or (mn0=5) or (mn0=7) or (mn0=8) or (mn0=10) or (mn0=12) then t_str0:=t_str0+'-16 12:00:00"';
       if (mn0=4) or (mn0=6) or (mn0=9) or (mn0=11) then t_str0:=t_str0+'-16"';
       if (mn0=2) and (IsLeapYear(yy0)=true) then t_str0:=t_str0+'-15 12:00:00"';
       if (mn0=2) and (IsLeapYear(yy0)=false) then t_str0:=t_str0+'-15"';
       end;

       if (cbService.ItemIndex=1) then t_str0:=t_str0+'-16"';

       if (chgMonth.Checked[mn0-1]=true) and
        (cancel_dl=false) then DownloadGlobalAnalysis(t_str0, t_str0, par_str, cmd0);
    if (chkScheduler.Checked=true) and (time>=dtpFinish.Time) then cancel_dl:=true;
   end;
  end;

   if rgGroupBy.ItemIndex=2 then begin
     DecodeDate(dtp1.Date, yy0, mn0, dd0);
     DecodeDate(dtp2.Date, yy1, mn1, dd1);

     for yy:=yy0 to yy1 do begin
      if (cbService.ItemIndex=0) or (cbService.ItemIndex=2) then begin
        t_str0:=inttostr(yy)+'-01-01 12:00:00"';
        t_str1:=inttostr(yy)+'-12-31 12:00:00"';
      end;
      if (cbService.ItemIndex=1)then begin
        t_str0:=inttostr(yy)+'-01-01 00:00:00"';
        t_str1:=inttostr(yy)+'-12-31 00:00:00"';
      end;
     if (cancel_dl=false) then DownloadGlobalAnalysis(t_str0, t_str1, par_str, cmd0);
     if (chkScheduler.Checked=true) and (time>=dtpFinish.Time) then cancel_dl:=true;
    end;

   end;
 end;

 finally
  btnDownloadMercator.Enabled:=true;
 end;
 cancel_dl:=false;
end;


procedure Tfrmmain.btnDownloadMissingClick(Sender: TObject);
var
  Ini: TIniFile;
  dat: text;
  k, c, pp, yy, mn: integer;
  st, par_str, t_str0, cmd0, usr, pwd, buf_str:string;
begin
 if OD.Execute then begin
  AssignFile(dat, OD.FileName); reset(dat);

   Ini := TIniFile.Create(IniFileName);
  try
   usr:=Ini.ReadString('dl_mercator', 'usr', '');
   pwd:=Ini.ReadString('dl_mercator', 'pwd', '');
  finally
   ini.Free;
  end;

  if (usr='') or (pwd='') then
   if MessageDlg('Update your Mercator username and password',
      mtWarning, [mbOk], 0)=mrOk then exit;


 par_str:='';
 for k:=0 to chgParameters.Items.Count-1 do begin
  if chgParameters.Checked[k]=true then begin
   Case k of
    0: par_str:=par_str+' --variable zos';      // sea_surface_height_above_geoid
    1: par_str:=par_str+' --variable mlotst';   // ocean_mixed_layer_thickness_defined_by_sigma_theta
    2: par_str:=par_str+' --variable so';       // sea_water_salinity
    3: par_str:=par_str+' --variable usi';      // eastward_sea_ice_velocity
    4: par_str:=par_str+' --variable vsi';      // northward_sea_ice_velocity
    5: par_str:=par_str+' --variable sithick';  // sea_ice_thickness
    6: par_str:=par_str+' --variable thetao';   // sea_water_potential_temperature
    7: par_str:=par_str+' --variable siconc';   // sea_ice_area_fraction
    8: par_str:=par_str+' --variable bottomT';  // sea_water_potential_temperature_at_sea_floor
    9: par_str:=par_str+' --variable uo';       // eastward_sea_water_velocity
   10: par_str:=par_str+' --variable vo';       // northward_sea_water_velocity
   end;
  end;
 end;
 trim(par_str);

 if par_str='' then
  if MessageDlg(SSelectParameters, mtWarning, [mbOk], 0)=mrOk then exit;

  while not eof(dat) do begin
    readln(dat, st);

    c:=11;
    for pp:=1 to 4 do begin
     buf_str:='';
     repeat
      inc(c);
       if (st[c]<>'_') then buf_str:=buf_str+st[c];
     until (st[c]='_') or (c=length(st));

     if pp=1 then seymin.Text:=buf_str;
     if pp=2 then seymax.Text:=buf_str;
     if pp=3 then sexmin.Text:=buf_str;
     if pp=4 then sexmax.Text:=copy(buf_str, 1, length(buf_str)-3);
    end;

  //  showmessage('here');

    cmd0:='-m motuclient '+
         '--user '+usr+' '+
         '--pwd '+pwd+' '+
         '--motu '+motu+' '+
         '--service-id '+service+' '+
         '--product-id '+product+' '+
         '--longitude-min '+sexmin.Text+' '+
         '--longitude-max '+sexmax.Text+' '+
         '--latitude-min '+seymin.Text+' '+
         '--latitude-max '+seymax.Text+' '+
         '--depth-min '+selev1.Text+' '+
         '--depth-max '+selev2.Text+' ';

      (* Daily *)
      if rgProduct.ItemIndex=0 then begin
       t_str0:=copy(st, 1, 10)+' 12:00:00"';
      end;

      (* Monthly *)
      if rgProduct.ItemIndex=1 then begin
       yy:=strtoint(copy(st, 1, 4));
       mn:=strtoint(copy(st, 6, 2));

       if (mn=1) or (mn=3) or (mn=5) or
          (mn=7) or (mn=8) or (mn=10) or (mn=12) then t_str0:=copy(st, 1, 10)+' 12:00:00"';
       if (mn=4) or (mn=6) or (mn=9) or (mn=11)  then t_str0:=copy(st, 1, 10);
       if (mn=2) and (IsLeapYear(yy)=true)  then t_str0:=copy(st, 1, 10)+' 12:00:00"';
       if (mn=2) and (IsLeapYear(yy)=false) then t_str0:=copy(st, 1, 10);
      end;

    if cancel_dl=false then DownloadGlobalAnalysis(t_str0, t_str0,  par_str, cmd0);

  end; // file
 end; // OD
end;



procedure Tfrmmain.DownloadGlobalAnalysis(t_str0, t_str1, par_str, cmd0: string);
Var
  fname, cmd:string;
begin
 fname:=Copy(t_str0, 1, 10)+'_'+seymin.Text+'_'+seymax.Text+'_'+sexmin.Text+'_'+sexmax.Text+'.nc';

 cmd:=cmd0+
      '--date-min "'+t_str0+' '+
      '--date-max "'+t_str1+' '+
      par_str+' '+
      '--out-dir '+GlobalPath+'data'+PathDelim+'mercator'+PathDelim+' '+
      '--out-name '+fname;

 //showmessage(cmd);

 frmmain.RunScript(cmd);
 Application.ProcessMessages;
end;


procedure Tfrmmain.btnCancelClick(Sender: TObject);
begin
 cancel_dl:=true;
 chkScheduler.Checked:=false;
 Timer1.Enabled:=false;
end;


procedure Tfrmmain.btnOpenFolderMercatorClick(Sender: TObject);
begin
  OpenDocument(GlobalPath+'data'+PathDelim);
end;



procedure Tfrmmain.chkSchedulerChange(Sender: TObject);
begin
  Timer1.Enabled:=chkScheduler.Checked;
end;

procedure Tfrmmain.Timer1Timer(Sender: TObject);
begin
 if chkScheduler.Checked=true then begin
   if timetostr(time)=timetostr(dtpStart.Time) then begin
     btnDownloadMercator.OnClick(self);
   end;
 end;
end;



procedure Tfrmmain.btnPythonPathClick(Sender: TObject);
begin
  OD.Filter:='Python.exe|Python.exe';
    if OD.Execute then ePythonPath.Text:= OD.FileName;
end;

procedure Tfrmmain.btnSavePassClick(Sender: TObject);
Var
  Ini:TIniFile;
begin
  Ini:=TIniFile.Create(IniFileName);
    try
      Ini.WriteString('dl_mercator', 'usr', eUser.Text);
      Ini.WriteString('dl_mercator', 'pwd', ePass.Text);
    finally
     Ini.Free;
    end;
end;

procedure Tfrmmain.btnShowInstalledClick(Sender: TObject);
begin

end;


procedure Tfrmmain.ePythonPathChange(Sender: TObject);
begin
 {$IFDEF WINDOWS}
  btnInstallMOTU.Enabled:=FileExists(ePythonPath.Text);
  btnUpgradeMOTU.Enabled:=FileExists(ePythonPath.Text);

  if FileExists(ePythonPath.Text) then
     ePythonPath.Font.Color:=clGreen else
     ePythonPath.Font.Color:=clRed;
 {$ENDIF}
end;


procedure Tfrmmain.btnInstallMOTUClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
mLog.Clear;
 Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteString ( 'main', 'PythonPath',  ePythonPath.Text);
  finally
   Ini.Free;
  end;

  RunScript('-m pip install motuclient');
end;


procedure Tfrmmain.btnUpgradeMOTUClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
mLog.Clear;
 Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteString ( 'main', 'PythonPath',  ePythonPath.Text);
  finally
   Ini.Free;
  end;

  RunScript('-m pip install motuclient --upgrade');
end;



procedure Tfrmmain.rgLanguageClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
 Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteInteger( 'main', 'Language', rgLanguage.ItemIndex);
   Application.ProcessMessages;
  finally
   Ini.Free;
  end;
end;


(* Launching scripts *)
procedure Tfrmmain.RunScript(cmd:string);
Var
  Ini:TIniFile;
  P:TProcess;
  ExeName, buf, s: string;
  WaitOnExit:boolean;
  i, j: integer;
begin
  Ini := TIniFile.Create(IniFileName);
  try
   ExeName:=Ini.ReadString('main', 'PythonPath', '');
   WaitOnExit:=false;
    if not FileExists(ExeName) then
      if Messagedlg(SNoPython, mtwarning, [mbOk], 0)=mrOk then begin
        cancel_dl:=true;
        exit;
      end;
  finally
   ini.Free;
  end;


 try
  P:=TProcess.Create(Nil);
  P.Commandline:=ExeName+' '+cmd;
//  showmessage(P.CommandLine);
  P.Options:=[poUsePipes, poNoConsole];
  if WaitOnExit=true then P.Options:=P.Options+[poWaitOnExit];
  P.Execute;

  repeat
   SetLength(buf, 3000);
   SetLength(buf, p.output.Read(buf[1], length(buf))); //waits for the process output
   // cut the incoming stream to lines:
   s:=s + buf; //add to the accumulator
   repeat //detect the line breaks and cut.
     i:=Pos(#13, s);
     j:=Pos(#10, s);
     if i=0 then i:=j;
     if j=0 then j:=i;
     if j = 0 then Break; //there are no complete lines yet.
       mLog.Lines.Add(Copy(s, 1, min(i, j) - 1)); //return the line without the CR/LF characters
       Application.ProcessMessages;
     s:=Copy(s, max(i, j) + 1, length(s) - max(i, j)); //remove the line from accumulator
   until false;
 until buf = '';
 if (s <> '') then begin
   mLog.Lines.Add(s);
   Application.ProcessMessages;
 end;
finally
 P.Free;
end;
end;



procedure Tfrmmain.btnDownloadMissing1Click(Sender: TObject);
begin

end;


end.

