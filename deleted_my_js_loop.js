//JSImageLoop |  The MIT License (MIT) | Copyright (c) 2014 Alan Brammer
// Modified by Kyle Griffin.
debug = false;

function updateValidTime(opts){
	var thetext = document.getElementById("valtime");
	var cycledate = timecode2Date(opts[0].timecode); 
	var fhr = opts.count * opts[0].increment;
	cycledate.setTime(cycledate.getTime()+(fhr*60*60*1000));
	datetext = myDateString(cycledate);
	thetext.innerHTML = "Valid: "+datetext;
}


function setbuttonfocus(opts){
        $("#"+opts.div).find('li').removeClass('active');
        $("#"+opts.div).find('.li_'+opts.row+'_'+opts.count).addClass('active');
        }


function change_image(opts){
        console_debug("changing image");
        opt = opts[opts.row];
	$("#"+opts.div).find('.img').attr('src', opt.images[opts.count].src );
        console_debug("    ----"+opt.images[opts.count].src);
        }

function check_loaded_buttons(opts){
        $.each( opts, function(o){
        for ( var i = opts[o].min; i <= opts[o].max; i++) {
            if(!opts[o].images[i].loaded ){
            $("#"+opts.div).find('.li_'+o+'_'+i).addClass('disabled');}else{
            $("#"+opts.div).find('.li_'+o+'_'+i).removeClass('disabled');}
            }});
            };


function check_loaded_button(opts, o,i){
            if(!opts[o].images[i].loaded ){
            $("#"+opts.div).find('.li_'+o+'_'+i).addClass('disabled');}else{
            $("#"+opts.div).find('.li_'+o+'_'+i).removeClass('disabled');}
            };


function draw(opts){
    console_debug( "Drawing for "+opts.div+ " Count:"+opts.count +" Row:"+ opts.row ) ;
    setbuttonfocus( opts );
    change_image(opts);
    draw_colorbar(opts);
    updateValidTime(opts);
};

function draw_colorbar(opts){
  if($("#"+opts.div).find('.colorbar') ){
    if( typeof opts[opts.row].colorbar != "undefined"  ){
      $("#"+opts.div).find('.colorbar').attr('src',  opts[opts.row].colorbar );
          $("#"+opts.div).find('.colorbar')[0].onload = function(){
            console_debug("colorbar w*h ="+$('#'+opts.div).find('.colorbar')[0].width+"  -- "+$('#'+opts.div).find('.colorbar')[0].height );
            if($('#'+opts.div).find('.colorbar')[0].width <$('#'+opts.div).find('.colorbar')[0].height ){
             $("#"+opts.div).find('.image').width( 1000+$('#'+opts.div).find('.colorbar')[0].width );
            };
          };
    }else{ $("#"+opts.div).find('.colorbar').attr('src',"") ;};
  };
};
    

function increment(e, opts){
    switch(e){
        case -1: opts.count = opts.count -1 ;         break;
        case 1: opts.count = opts.count +1 ;          break;
        case 2: opts.row = opts.row -1 ;              break;
        case 3: opts.row = opts.row +1 ;              break;
        default: return;     // Not really needed here but no harm.
       };

   if( opts.row < 0 ) { opts.row = 0 };
   if(opts.row > opts.length-1) {opts.row = opts.length-1 };
   if ( opts.count <  opts[opts.row].min ) {
        if( opts.loop ){ opts.count = opts[opts.row].max ;}
        else{ opts.count = opts[opts.row].min; }
        };
   if ( opts.count >  opts[opts.row].max ) {
        if( opts.loop ){ 
		if(opts.animating){
		clearTimeout(opts.animator); 
		opts.animating = false; 
		setTimeout(function(){ 
			opts.count = opts[opts.row].min-1; 
			play(opts); 
			},200);
		opts.count = opts[opts.row].max 
		}
		else{opts.count = opts[opts.row].min}}
        else{ opts.count = opts[opts.row].max; }
        };
    if(!opts[opts.row].images[opts.count].loaded){
     if(e == 2){e=3}else if(e==3){e=2};
     increment(e, opts);
     }else{
    draw(opts);
    console_debug("Done and can go home");
    };
    };

function jump2(e){
        name = e.parents('.holder').attr('id');
        info =  e.attr('class').split("_") ;
        nrow = parseInt(info[1]); ncol = parseInt(info[2]);
        if(useroptions[name][nrow].images[ncol].loaded){
         useroptions[name].row = parseInt(info[1]);
         useroptions[name].count = parseInt(info[2]);
         draw( useroptions[name] );
        };};


function play(ele){
    if(!ele.animating){
    ele.animating = true
    ele.animator = setInterval(function(){increment(1, ele)},200)
    }else{
    clearTimeout(ele.animator);
    ele.animating = false; };
    };

function load(ele){
    imageObj = new Image();
    start_count = ele.count
//     $("#"+opts.div).addClass('
    // This will loop over all of the images to show they are loaded.
    //ele.animator = setInterval( function(){increment(1, ele); if(ele.count == start_count){ clearTimeout(ele.animator); }} ,100)
    draw(ele); //update visible image only
    check_loaded_buttons(ele); //check for 'loaded' state upon each new loading of images. 
    startTimer(ele);

};

//function startTimer(ele){
//	var timervar = setInterval(function(){load(ele)},30000);
//};


function myTimer() {
    var d = new Date();
};


function console_debug(text){ if(typeof debug != 'undefined' && debug ){ console.log(text); }; };



function build_buttons(opts){
    text ="<div class='navbar'>"
    $.each( opts, function(o){
        console_debug("+++++++++++ Buttons");
        console_debug(opts);
        text += "<ul>"
        if( typeof opts[o].title !== 'undefined'){
            if(opts[o].title.length > 15){fsize = '12px'}
            else{fsize = '18px'}

        text+="<li class=title style='font-size:"+fsize+"'> "+opts[o].title+"</li>"}
        else{text+="<li class=title > </li>" }
        for ( var i = opts[o].min; i <= opts[o].max; i++) {
            text+="<li class=li_"+o+"_"+i+"> "+opts[o].labels[i]+"</li>";
            //if(i%opts[o].label_interval === 0){
            //text+="<li class=li_"+o+"_"+i+" title='"+opts[o].labels[i]+"'> "+opts[o].labels[i]+"</li>";
            //}else{
            // text+="<li class=li_"+o+"_"+i+" title='"+opts[o].labels[i]+"'>&nbsp;</li>";
            //};
        };
        text+="</ul></br>";
        });
            text +="</div>"
        return( text);
        };


function fspan(mn, mx, inc){
    var retval = [];
    for	(i = mn; i <= mx; i+=inc) {
    retval.push( i );
    };
    return  ( retval ) ;
    };

//KG: Add function for padding numbers with leading 0s up to size numbers
function pad(num, size) {
    var s = num+"";
    while (s.length < size) s = "0" + s;
    return s;
};


function loadimage(src, callback){
        imageObj = new Image();
        imageObj.onload = callback;
        imageObj.src = src;
};



function add_colorbar(opts){      

        console_debug("adding colorbar"); 
        if( typeof opts['colorbar'] === 'undefined'){console_debug("no colorbar defined"); return( false )};
  
        colorbar_img = new Image();            
        $(colorbar_img).on('load', function(){
             if(colorbar_img.width === colorbar_img.height &&  colorbar_img.height === 0){return(false);};
             if(colorbar_img.width > colorbar_img.height){
                console_debug("horizontal colorbar");
                }else{
                console_debug("horizontal colorbar");
             };
             console_debug(" Adding colorbar: "+colorbar_img.src );
          });
        colorbar_img.src = opts.colorbar;
        return( true )
        };


function build_input(opts){
        //  First; Either build url links or copy.
        if(typeof opts['increment'] === 'undefined'){
            opts.increment = 1;};
        if(typeof opts['prefix'] === 'undefined'){
            opts.prefix = "";};
        if(typeof opts['extension'] === 'undefined'){
            opts.extension = ".jpg";};
        if( typeof opts['filenames'] === 'undefined'){
           opts.values = fspan(opts.minval, opts.maxval, opts.increment );
        }else{
            opts.values = opts.filenames;
        };
	//KG: Add padding in response to opts.pad setting, if set
        if(typeof opts['pad'] !== 'undefined'){
          if(opts.pad >= 1){
            for(i = 0; i<opts.values.length; i++) {
              opts.values[i] = pad(opts.values[i],opts.pad);
            };
	  };
        };
        if( typeof opts['timecode'] === 'undefined'){
           opts.timecode = "";
        };
        //KG: added other codes for variable and region
        if( typeof opts['varcode'] === 'undefined'){
           opts.varcode = "";
        };
        if( typeof opts['regcode'] === 'undefined'){
           opts.regcode = "";
        };

        console_debug(opts.values.length)
        opts.min = 0;
        opts.max = opts.values.length-1;
        
        delete(opts.images)
        opts.images = [];
        opts.loaded = [];
        imageObj = new Image();
        //KG: Changed the image url for a root/date/var/var_reg_date_num.ext format
        for( var i=opts.min; i<= opts.max; i++){
         opts.images.push( new Image() );
         opts.images[i].loaded = false;
         opts.images[i].varno = opts.varno;
         opts.images[i].imgno = i;
         opts.images[i].onload = function(i){this.loaded = true; console.log("loaded"+this.varno+" "+this.imgno); 
	 check_loaded_button(useroptions[opts.div_id],this.varno,this.imgno );};
         opts.images[i].src = opts.prefix+opts.timecode+"/"+opts.varcode+"/"+opts.varcode+"_"+opts.regcode+"_"+opts.timecode+"_"+opts.values[i]+opts.extension
          }

        console_debug( " -- Min: "+opts.min+", Max: "+opts.max );

        if(typeof opts['labels'] === 'undefined'){
           opts.labels = opts.values;
        ;}
        
        if(opts.labels.length != opts.values.length){
        opts.labels = (opts.values);}

        if( typeof opts.startingframe === 'undefined'){
           opts.startingframe = opts.min;
        }else{
            opts.startingframe  = Math.max(opts.startingframe, opts.min);
            opts.startingframe  = Math.min(opts.startingframe, opts.max);
        };

    console_debug(opts);
    };


$(function () {

 $.each(Object.keys(useroptions), function(k,key){
        if(!document.getElementById(this)){
        $('body').append('<div id='+this+' class="holder"  tabindex="0" ></div><br>');};
            ele = document.getElementById(this);
            $(ele).attr("tabindex", 0);
            $(ele).addClass("holder");
            $(ele).append(' <font style="font-size:10; text-align:center">  Arrow keys for navigation | Space = play/pause | Swipe for navigation on touchscreen </font>');
        useroptions[this].div_id = key;
        text=""
        if( ele === null){console.log(this+" div is not defined!!!" );return true} // If Div is not defined ignore options and move on.
        $.each( useroptions[this], function(i){
	    this.varno = i;
            console_debug(this.title+","+i+" and some more content");
            console_debug( "Initiating " + this.title );
	    this.div_id = key;
            update_from_url(this);
            build_input(this);
        });
        useroptions[this].row=0;
        useroptions[this].count=useroptions[this][useroptions[this].row].startingframe;
        useroptions[this].loop=true;
        useroptions[this].div=this;
        text+= build_buttons(useroptions[this]) ;
        text+= "<div class='image'><img class='img'>";
        $.each( useroptions[this], function(){
            if( add_colorbar( this )){
            text+= "<img class='colorbar' id='colorbar' >";
            return false;
            }
        text+="</div>";
        });
        $(ele).append( text );
        draw(useroptions[this]);
        check_loaded_buttons(useroptions[this]);
        });
        $( '#'+Object.keys(useroptions)[0] ).focus();

   $('div').bind('keydown', function(e) {
       console_debug(this.id +" button pressed "+ e.which);
       switch(e.which) {
           case 37: increment(-1, useroptions[this.id]);             break;
           case 39:  increment(1, useroptions[this.id] );           break;
           case 32:  play(useroptions[this.id]);                    break;
           case 38:  increment(2, useroptions[this.id] );           break;
           case 40:  increment(3, useroptions[this.id] );           break;
           default: return; // exit this handler for other keys
       }
       e.preventDefault(); // prevent the default action (scroll / move caret)
   });

    $("div").bind('swipeup',   function(e){  e.stopImmediatePropagation(); increment(2,  useroptions[$(this).parent('.holder').attr('id')] )  });
    $("div").bind('swipedown', function(e){  e.stopImmediatePropagation(); increment(3,  useroptions[$(this).parent('.holder').attr('id')] )  });
    $("div").bind('swiperight',function(e){  e.stopImmediatePropagation(); increment(-1, useroptions[$(this).parent('.holder').attr('id')] )  });
    $("div").bind('swipeleft', function(e){  e.stopImmediatePropagation(); increment(1,  useroptions[$(this).parent('.holder').attr('id')] )  });

    $("li").click(function(){ jump2( $(this) ); });

});



$(document).ready(function(){
    $("div").bind('doubletap', function(){  play(useroptions[$(this).parent('.holder').attr('id')])  });
});

