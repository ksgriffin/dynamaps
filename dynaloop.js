function getUrlParams() {
    var vars = {};
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
        vars[key] = value;
    });
    return vars;
};

function getURLParameter(name) {
	  return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null
};

function getUrlValue(VarSearch){
  var SearchString = window.location.search.substring(1);
  var VariableArray = SearchString.split('&');
  for(var i = 0; i < VariableArray.length; i++){
    var KeyValuePair = VariableArray[i].split('=');
    if(KeyValuePair[0] == VarSearch){
      return KeyValuePair[1];
    }
  }
  return ""
}


/**
* Add a URL parameter (or changing it if it already exists)
* @param {search} string  this is typically document.location.search
* @param {key}    string  the key to set
* @param {val}    string  value 
*/
var addUrlParam = function(search, key, val){
  var newParam = key + '=' + val,
      params = '?' + newParam;

  // If the "search" string exists, then build params from it
  if (Boolean(search)) {
    // Try to replace an existance instance
    params = search.replace(new RegExp('[\?&]' + key + '[^&]*'), newParam);
     console.debug("Replaced a parameter.");
    // If nothing was replaced, then add the new param to the end
    if (params === search) {
      params += '&' + newParam;
    }
  }

  return params;
};


function addParam(url, param, value) {
  var a = document.createElement('a'), regex = /[?&]([^=]+)=([^&]*)/g;
  var match, str = []; a.href = url; value=value||"";
  while (match = regex.exec(a.search))
  if (encodeURIComponent(param) != match[1]) str.push(match[1] + "=" + match[2]);
  str.push(encodeURIComponent(param) + "=" + encodeURIComponent(value));
  a.search = (a.search.substring(0,1) == "?" ? "" : "?") + str.join("&");
  return a.href;
}



function update_from_url(opts){
  var vars = getUrlParams(); 
  //opts.stimecode = vars["stime"];
  //opts.etimecode = vars["etime"];
  opts.timecode = vars["time"];
  opts.varcode = vars["var"];
  opts.regcode = vars["reg"];
  //set_selected(opts.stimecode);
  //set_selected(opts.etimecode);
  set_selected(opts.timecode);
  set_selected(opts.varcode);
  set_selected(opts.regcode);

};

function set_selected(val){
  var opt = $("option[value="+val+"]"),
    html = $("<div>").append(opt.clone()).html();
  html = html.replace(/\>/, ' selected="selected">');
  opt.replaceWith(html);
};

function update_url(opts){
  //var string_to_add = addUrlParam(document.location.search,'stime',this.stimecode);
  //string_to_add = addUrlParam(string_to_add,'etime',this.etimecode);
  //var string_to_add = addParam(string_to_add,'time',this.timecode);
  //string_to_add = addParam(string_to_add,'var',this.varcode);
  //string_to_add = addParam(string_to_add,'reg',this.regcode);
  console.log(opts)
  var string_to_add = "?time="+opts.timecode+"&reg="+opts.regcode+"&var="+opts.varcode;
  alert((opts.timecode)+"\n"+string_to_add);
  document.location.search = string_to_add;
};

function currentCycle() {
  cdate = new Date();
  hour = Math.floor((cdate.getUTCHours()-3)/6)*6;
  //if(cdate.getUTCHours()<3) { cdate.setTime(cdate.getTime()-(24*60*60*1000)); }
  cdate.setUTCHours(hour);
  return formatCycle(cdate);
};

function formatCycle(cdate) {
    //Assumes cdate is a js date at the cycle's time
    //This just formats that date into yymmddhh
    hour = cdate.getUTCHours();
    month = cdate.getUTCMonth()+1;
    day = cdate.getUTCDate();
    if(month<10) {month = "0"+month;}
    if(day<10) {day="0"+day;}
    if(hour<10) {hour="0"+hour;}
    curtime = (cdate.getUTCFullYear()%100)+""+month+""+day+""+hour;
    return curtime;
};

function myDateString(dobj) {
  var weekday = new Array();
  weekday[0] = "Sun";
  weekday[1] = "Mon";
  weekday[2] = "Tue";
  weekday[3] = "Wed";
  weekday[4] = "Thu";
  weekday[5] = "Fri";
  weekday[6] = "Sat";
  var monthstr = new Array();
  monthstr[0] = "Jan";
  monthstr[1] = "Feb";
  monthstr[2] = "Mar";
  monthstr[3] = "Apr";
  monthstr[4] = "May";
  monthstr[5] = "Jun";
  monthstr[6] = "Jul";
  monthstr[7] = "Aug";
  monthstr[8] = "Sep";
  monthstr[9] = "Oct";
  monthstr[10] = "Nov";
  monthstr[11] = "Dec";

  hh = dobj.getUTCHours();
  mm = dobj.getUTCMinutes();
  if(hh<10) { hh = "0"+hh; }
  if(mm<10) { mm = "0"+mm; }
  utc_time = hh+""+mm;

  var dstring = weekday[dobj.getUTCDay()]+" "+dobj.getUTCDate()+" "+monthstr[dobj.getUTCMonth()]+" "+utc_time+" UTC";

  return dstring;
};

function addDropOption(selectbox,text,value ) {
	var optn = document.createElement("option");
	optn.text = text;
	optn.value = value;
	selectbox.options.add(optn);
};

function createTimeList(selectbox) {
	var cdate = new Date();
	var chh = cdate.getUTCHours();
        var cycle = 18;
	if (chh < 3) { cycle = 18; cdate.setTime(cdate.getTime()-(24*60*60*1000)) }
	else if (chh < 9) { cycle = 0; }
	else if (chh < 15) { cycle = 6; }
	else if (chh < 21) { cycle = 12; }
	else { cycle = 18; }
	cdate.setUTCHours(cycle);
	cdate.setUTCSeconds(00);
	cdate.setUTCMinutes(00);
	var lastdate = new Date(cdate);
	var thisdate = new Date(cdate);
	lastdate.setTime(lastdate.getTime()-(14*24*60*60*1000)); //14 is days to keep
	//assumes increments of 6 hours - can be changed
	while(thisdate.getTime() > lastdate.getTime()) {
//		alert(thisdate.toUTCString());
		addDropOption(selectbox,myDateString(thisdate),formatCycle(thisdate));
		thisdate.setTime(thisdate.getTime()-(6*60*60*1000));
	}
};

function timecode2Date(tcode) {
	var yy = Math.floor(tcode/1000000);
	var mm = Math.floor(tcode/10000)%100;
	var dd = Math.floor(tcode/100)%100;
	var hh = tcode%100;
        //pad is from another js file.
	mm = pad(mm-1,2);
	dd = pad(dd,2);
	hh = pad(hh,2);
	var retdate = new Date("20"+yy,mm,dd,hh,00,00,0);
	retdate.setTime(retdate.getTime() - (retdate.getTimezoneOffset()*60*1000));
//	return( new Date("20"+yy,mm,dd,hh,00,00,0));
	return( retdate );
};
