class ChessController < ApplicationController
  def new
  end
    
  def game
    @custom_stylesheet = true
    render 'public/chess2', layout: false
  end

end
