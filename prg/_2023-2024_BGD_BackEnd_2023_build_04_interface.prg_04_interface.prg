%majVer = "1"
%minVer = "2"
%maxrows = "170"
%AFtype = "i"
%freq = "A"
%xtractysheets="NA-Prodn-Vol NA-Prodn-P Labor Fiscal-Summary Fiscal-Revenues Fiscal-Expenditures"
%xtraglobsheets="Global Commodities"
%xtrarepsheets="Reports"

string isim_ctyvars=""
string isim_fisf_vars="" 
string isim_fiscn_cty =""
string isim_fiscp_cty =""
string isim_fiscp_vars =""
string isim_fy_ctyvars=""
string isim_countries=%cty
string isim_fiscf_cty=%cty
string remt_countries=%cty
string prod_countries=%cty
string cpi_countries=%cty
string kacc_countries=""
string mfm_kacc_cty=""
string mfmod_thissoln_ctylist=%cty
string ifaceversion="1.0"

' string mfmsa_AFtype="i" 
' string mfmsa_xtractysheets="NIA-Prod"
' string mfmsa_xtraglobsheets="Externe"
' string mfmsa_xtrarepsheets="Reports"
' string tobeexog=""
' string c_spec_qi=quasi_identity
' string exog=""
' string endog=""
' string shold=""
' string ifacestart=%display_start
' string ifaceend=%display_end
' string ihistend=%end_date
' string isolvestart=%solve_start
' string isolveend=%display_end

string mfmsaoptions = "<?xml version=""1.0"" encoding=""UTF-8""?><MFMSAoptions><majVer>"+%majVer + "</majVer><minVer>"+ %minVer + "</minVer><iFace><country>" + %cty + "</country><DispStart>" + %display_start + "</DispStart><DispEnd>" + %display_end + "</DispEnd><SolveStart>" + %solve_start + "</SolveStart><SolveEnd>" + %display_end + "</SolveEnd><HistEnd>" + %end_date_interface + "</HistEnd><maxRows>" +  %maxrows + "</maxRows><AFType>" + %AFtype + "</AFType><SolnType>" + %solve_method + "</SolnType><Freq>" + %freq + "</Freq></iFace><Sheets><global>" + %xtraglobsheets + "</global><country>" + %xtractysheets + "</country><reports>" + %xtrarepsheets + "</reports></Sheets><custStrings><quasiIdentities>" + quasi_identity + "</quasiIdentities><Collab><Type>0</Type><Affix></Affix><Direct></Direct><Main><Name></Name><Affix></Affix></Main><Subs><Sub><Name></Name><Affix></Affix></Sub></Subs></Collab></custStrings></MFMSAoptions>"


