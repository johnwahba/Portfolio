$( -> 
	Chess.ChessUI = class ChessUI
		constructor:(game)->
			@game = game
			that = this
			$('div').on('click','div', (event) -> that.clickSquare(event, this) )
			this.drawTable()
			this.drawPieces(@game.board)

			if @game.current_player.type == "computer"
				this.clickSquare()

		cssSelector: (array)->
			"#\\3" + array[0].toString() + "\\," + array[1].toString()



		toggleColor: (color)->
			if color == "black" 
				return "white"
			else
				return "black"

		drawTable: ->
			table = $('.chessboard')
			chessSquares = ""
			for y in [1..8] 
				color = this.toggleColor(color)
				for x in [1..8]
					color = this.toggleColor(color)
					chessSquares += "<div class='square " + color + "' id='" + String(x) + "," + String(y) + "'></div>"
				chessSquares += "<br>"
			table.append(chessSquares)
			ChessUI.squares = $('.square')


		drawPieces:(board, $board) ->
			for piece in [board.pieces().white..., board.pieces().black...]
				pieceDiv = "<img class='piece' src='/assets/chesspieces/" + piece.string + ".png'>"
				$('#' + piece.cssSelector()).append(pieceDiv)



		selected = null

		clickSquare: (event, coord) ->
			movePossible = $(coord).hasClass('highlighted-move')
			for square in ChessUI.squares
				$(square).removeClass("highlighted-piece")
				$(square).removeClass("highlighted-move")
			piece = @game.board.pos([coord.id[0], coord.id[2]]) if coord
			piece or= {}
			if !selected && piece.color == @game.current_player.color# && game.current_player.type == 'human'
				if piece
					for move in @game.ruleBook.availableMoves(piece)
						$(this.cssSelector(move)).addClass('highlighted-move')
					$(coord).addClass("highlighted-piece") 
					selected = $(coord)[0]
			else if selected != coord && movePossible 
				this.forceMovePiece(selected, coord)
				this.game.playTurn([[selected.id[0], selected.id[2]], [coord.id[0], coord.id[2]]])
				selected = null
			else
				selected = null
			if @game.current_player.type == 'computer' && !@game.ruleBook.playerWon()
				move = @game.current_player.moveChoice()
				this.forceMovePiece(this.cssSelector(move[0]), this.cssSelector(move[1]))
				@game.playTurn(move)
				unless @game.ruleBook.playerWon()
					this.clickSquare()
				# if selected.id != coord.id

		forceMovePiece: (startPos, endPos) ->
			$(endPos).html("")
			$(endPos).append($(startPos).html())
			$(startPos).html("")



	)