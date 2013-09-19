// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//= require jquery
//= require jquery_ujs
//= require chessboard
//= require chessboardUI
//= require bootstrap
//= require_tree .

$(function(){
	$('#rulebook').on('click', function(event){
		if(event.target.id == 'Losing'){
			$('[value="AIPlayer"]').hide(400);
			$('[value="AIPlayer"]').removeClass('active');
		} else if (event.target.id == 'Standard'){
			$('[value="AIPlayer"]').show(400);
		}
	});

	$('#submit').on('click', function(event){
		if($('.active').length == 3){
			var rulebook = $('.active[name=rulebook]').attr('value');
			var whitePlayer = $('.active[name=whitePlayer]').attr('value');
			var  blackPlayer = $('.active[name=blackPlayer]').attr('value');
			window.location.assign(document.URL + "/" + whitePlayer + "/" + blackPlayer + "/" + rulebook)
		}
	});
});