window.Chess = class Chess

	Chess.Board = class Board
		constructor: (emptyBoard)->
			b = "black"
			w = "white"
			@boardObject = {}
			for x in [1..8]
				@boardObject[x] = {}
			@kings = {}
			unless emptyBoard
				for set in [[1, b],[8, w]]
					start = [
						[[[1, set[0]], [8, set[0]]], Rook, set[1]]
						[[[2, set[0]], [7, set[0]]], Knight, set[1]] 
						[[[3, set[0]], [6, set[0]]], Bishop, set[1]] 
						[[[4, set[0]]], Queen, set[1]] 
						[[[5, set[0]]], King, set[1]] 
					]
					this.place(pieces...) for pieces in start


				for set in [[2, b],[7, w]]
					for x in [1..8]
						this.place( [[x, set[0]]], Pawn, set[1] )


		boardDup:->
			duppedBoard = new Board({})
			for piece in this.pieces(true)
				newPiecePosition = piece.positon
				newpieceConstructor = piece.__proto__.constructor
				newPieceColor = piece.color
				duppedBoard.place([piece.position], newpieceConstructor, newPieceColor)
			duppedBoard


		place: (positions, piece, color) ->
			for coord in positions 
				@boardObject[coord[0]][coord[1]] = new piece(coord, this, color)

		pieces: (array) ->
			if array
				output = []
				for x in [1..8]
					for y in [1..8]
						piece = this.pos([x,y])
						if piece
							output.push(piece)
			else
				output = {"black" : [], "white" : []}
				for x in [1..8]
					for y in [1..8]
						piece = this.pos([x,y])
						if piece
							if piece.color == "white"
								output.white.push(piece)
							else
								output.black.push(piece)
			output


		remove: (position) ->
			@boardObject[position[0]][position[1]] = undefined

		pos: (xy) ->
			if this.onBoard(xy) then @boardObject[xy[0]][xy[1]] else undefined

		onBoard:(xy) ->
			parseInt(xy[0]) in [1..8] and parseInt(xy[1]) in [1..8]

		forceMove: (startPosition, endPosition)->
			piece = this.pos(startPosition)
			piece.forceMove(endPosition)


	Chess.Piece = class Piece

		constructor: (@position, @board, @color, options) ->
			@deltas = []
			if options && options.diag 
				@deltas.push d for d in [[1,1],[-1,1],[1,-1],[-1,-1]]
			if options && options.horiz 
				@deltas.push d for d in [[1,0],[-1,0],[0,1],[0,-1]]

		forceMove: (position) ->
			old = this.position
			this.position = [parseInt(position[0]), parseInt(position[1])]
			this.board.remove(old)
			this.board.boardObject[position[0]][position[1]] = this

		enemy: (coord) ->
			this.board.pos(coord) && this.board.pos(coord).color != this.color

		friend: (coord) ->
			this.board.pos(coord) && this.board.pos(coord).color == this.color

		cssSelector:->
			"\\3" + @position[0].toString() + " \\," + @position[1].toString()


	Chess.SlidingPiece = class SlidingPiece extends Piece

		validMoves: ->
			output = []
			for delta in this.deltas
				finished = false
				offset = 1
				until finished
					current = [this.position[0] + delta[0] * offset,
					  		   this.position[1] + delta[1] * offset]
					if this.enemy(current)
						finished = true

					if this.friend(current) || !this.board.onBoard(current)
						finished = true
						break

					output.push(current)
					offset++ 
			output


	Chess.HoppingPiece = class HoppingPiece extends Piece
		validMoves: ->
			output = []
			for delta in this.deltas
				current = [this.position[0] + delta[0],
				  		   this.position[1] + delta[1]]
				unless this.friend(current) || !this.board.onBoard(current)
					output.push(current) 
			output

	Chess.Rook = class Rook extends SlidingPiece
		constructor: (position, board, color) ->
			super(position, board, color, {horiz : true}) 
			@string = color[0] + "R"
			@value = 5


	Chess.Knight = class Knight extends HoppingPiece
		constructor: (position, board, color) ->
			super(position, board, color)
			@deltas = [[2,1],[1,2],[-2,1],[1,-2],[2,-1],[-1,2],[-2,-1],[-1,-2]]
			@string = color[0] + "N"
			@value = 3

	Chess.King = class King extends HoppingPiece
		constructor: (position, board, color) ->
			super(position, board, color, {diag : true, horiz : true})
			board.kings[color] = this
			@string = color[0] + "K"
			@value = 1000

	Chess.Pawn = class Pawn extends HoppingPiece
		constructor: (position, board, color) ->
			super(position, board, color)
			if color == "white"
				@y = -1 
			else 
				@y = 1
			@move = [0,@y]
			@captures = [[1, @y], [-1, @y]]
			@string = color[0] + "P"
			@value = 1

		validMoves: ->
			output = []
			move = [this.position[0] + @move[0], this.position[1] + @move[1]]
			if !this.board.pos(move) && this.board.onBoard(move)
				output.push(move)
				if ((move[1] == 6 && this.color == 'white') ||
				(move[1] == 3 && this.color == 'black')) && !this.board.pos([move[0],move[1] + @y])
					output.push([move[0],move[1] + @y])
			for coord in @captures
				capture = [coord[0] + this.position[0], coord[1] + this.position[1]]
				if this.enemy(capture) 
					output.push(capture)

			output


	Chess.Bishop = class Bishop extends SlidingPiece
		constructor: (position, board, color) ->
			super(position, board, color, {diag : true})
			@string = color[0] + "B"
			@value = 3

	Chess.Queen = class Queen extends SlidingPiece
		constructor: (position, board, color) ->
			super(position, board, color, {diag : true, horiz : true}) 
			@string = color[0] + "Q"
			@value = 9

	Chess.RuleBook = class RuleBook
		constructor:->
			@board = new Board

		playerCaptureMoves:(color, withStartingCoord, board)->
			board ||= @board
			output = []
			for piece in board.pieces()[color]
				pieceCaptures = this.pieceCaptureMoves(piece, board)
				if pieceCaptures.length
					if withStartingCoord
						output.push([piece.position, pieceCaptures])
					else
						output.push(pieceCaptures...)
			output

		pieceCaptureMoves:(piece, board) ->
			board ||= @board 
			output = []
			for move in piece.validMoves()
				output.push(move) if board.pos(move) && board.pos(move).color != piece.color
			output


	Chess.Standard = class Standard extends RuleBook

		inCheck:(color, board)->
			board ||= @board
			opponent = this.opponent(color)
			captureMovesString = this.playerCaptureMoves(opponent, null, board).map (coord)-> coord.toString() 
			if board.kings[color].position.toString() in captureMovesString
				return true
			return false

		opponent:(color)->
			return "black" if color == "white"
			"white" if color == "black"

		playerValidMoves:(color, withStartingCoord, board)->
			board ||= @board
			output = []
			if withStartingCoord
				 for piece in board.pieces()[color] 
				 	if piece.validMoves().length
				 		for endPos in piece.validMoves()
				 			tempBoard = board.boardDup()
				 			tempBoard.forceMove(piece.position, endPos)
				 			unless this.inCheck(color, tempBoard)
				 				output.push([piece.position, endPos])
			else
				for piece in board.pieces()[color]
					if piece.validMoves().length
						suboutput = []
						for endPos in piece.validMoves()
				 			tempBoard = board.boardDup()
				 			tempBoard.forceMove(piece.position, endPos)
				 			unless this.inCheck(color, tempBoard)
				 				suboutput.push(endPos)
						output.push([piece.position, suboutput]) if suboutput.length
			output

		inCheckMate:(color)->
			opponent = this.opponent(color)
			return false unless this.inCheck(color)
			for move in this.playerValidMoves(color, true)
				tempBoard = @board.boardDup()
				piece  = tempBoard.pos(move[0])
				piece.forceMove(move[1])
				unless this.inCheck(color, tempBoard)
					return false
			true
			

		availableMoves:(piece, board)->
			board ||= @board
			output = []
			for move in piece.validMoves()
				tempBoard = board.boardDup()
				newPiece  = tempBoard.pos(piece.position)
				newPiece.forceMove(move) 
				unless this.inCheck(piece.color, tempBoard.board)
					output.push(move)
			output

		playerWon: ->
			if this.inCheckMate('white')
				"black"
			else if this.inCheckMate('black')
				"white"
			else
				null

	Chess.LosingChess = class LosingChess extends RuleBook


		playerValidMoves: (color, withStartingCoord) ->
			output = []
			if this.playerCaptureMoves(color).length
				return  this.playerCaptureMoves(color, withStartingCoord)
			if withStartingCoord
				 for piece in @board.pieces()[color] 
				 	if piece.validMoves().length
				 		for endPos in piece.validMoves()
				 			output.push([piece.position, endPos])
			else
				output.push(piece.validMoves()...) for piece in @board.pieces()[color]
			output

		availableMoves:(piece)->
			if this.playerCaptureMoves(piece.color).length
				return this.pieceCaptureMoves(piece)
			else
				return piece.validMoves()

		playerWon:->
			if @board.pieces().white.length == 0
				'white'
			else if @board.pieces().black.length == 0
				'black'
			else
				null


	Chess.Player = class Player
		constructor: (@color, @ruleBook)->
			

	Chess.HumanPlayer = class HumanPlayer extends Player
		constructor:(color, ruleBook)->
			@type = "human"
			super(color, ruleBook)

	Chess.RandomPlayer = class RandomPlayer extends Player
		constructor:(color, ruleBook)->
			@type = "computer"
			super(color, ruleBook)

		moveChoice:->
			possibleMoves = @ruleBook.playerValidMoves(@color, true)
			pieceToMove = possibleMoves[Math.floor(Math.random() * possibleMoves.length)]
			pieceToMove

	Chess.StandardAIPlayer = class AIPlayer extends Player
		constructor: (color, ruleBook, level)->
			@type = "computer"
			@level = level || 1
			super(color, ruleBook)

		scoreBoard:(color, board)->
			this.valueOfBoardBalance(color, board) 

		valueOfBoardBalance:(color, board)->
			opponent = @ruleBook.opponent(color)
			return -100000 if @ruleBook.inCheckMate(color)
			return 100000 if @ruleBook.inCheckMate(opponent)
			board.pieces()[color].reduce (accum, piece) ->
				accum + piece.value
			, 0 - 
			board.pieces()[opponent].reduce (accum, piece) ->
				accum + piece.value
			, 0


		valueOfUnprotectedAndThreatened: (color, board)->
			opponent = @ruleBook.opponent(color)
			output = 0
			for defendingPiece in board.pieces()[color]
				for assaultingPiece in board.pieces()[opponent]
					if defendingPiece.position in @ruleBook.availableMoves(assaultingPiece, board)
						if assaultingPiece.value < defendingPiece.value
							output += defendingPiece.value
						else
							tempBoard = @board.boardDup()
							tempBoard.forceMove(assaultingPiece.position, defendingPiece.position)
							assualtingPieceClone = tempBoard.pos(assaultingPiece.position)
							unless assaultingPieceClone.position in @ruleBook.playerValidMoves(color,null,tempBoard)
			 					output += defendingPiece.value
			output

		moveChoice:(board1, level)->
			#Minimax implementation
			board = board1 || @ruleBook.board
			level ||= @level
			currentMove = []
			#Minimize currentMoveValue
			currentMoveValue = 10000
			currentCounterValue = -10000 
			for move in @ruleBook.playerValidMoves(@color, true, board)
				tempMasterBoard = board.boardDup()
				tempMasterBoard.forceMove(move...)
				currentCounter = []
				currentCounterValue = -10000
				for counterMove in @ruleBook.playerValidMoves(@ruleBook.opponent(@color), true, tempMasterBoard)
					tempBoard = tempMasterBoard.boardDup()
					tempBoard.forceMove(counterMove...)
					debugger if String(counterMove) == String([[8,8],[8,7]])
					if level <= 1
						opponentScore = this.scoreBoard(@ruleBook.opponent(@color), tempBoard)
					else
						opponentScore = this.moveChoice(tempBoard, level - 1)[1]
					if opponentScore > currentCounterValue
						currentCounterValue = opponentScore
						currentCounterMove = counterMove
						if currentCounterValue > currentMoveValue
							break
				if currentCounterValue <= currentMoveValue
					currentMove = move
					currentMoveValue = currentCounterValue
			if board1
				return [currentMove, currentMoveValue]
			else
				return currentMove








	Chess.Game = class Game
		constructor: (player1, player2, ruleBook) ->
			@ruleBook = new ruleBook
			@board = @ruleBook.board
			@player1 = new player1('white', @ruleBook)
			@player2 = new player2('black', @ruleBook)
			@current_player = @player1
		# [[8,7],[8,6]]
		playTurn:(move)->
			piece = @ruleBook.board.pos(move[0])
			#JS can't compare arrays for equality
			if piece 
				validMovesString = piece.validMoves().map (el) -> el.toString() 
			if piece && move[1].toString() in validMovesString
				if @current_player == @player1 
					@current_player = @player2 
				else
					@current_player = @player1
				@board.pos(move[0]).forceMove(move[1])
			else
				alert('invalid move')

