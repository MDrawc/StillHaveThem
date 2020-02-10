class EditNotif < ApplicationService
  def initialize(game:, ex_platform:, ex_physical:)
    @game = game
    @ex_platform = ex_platform
    @ex_physical = ex_physical
  end

  def call
    message = "<span class='g'>Edited</span> #{ @game.name }: " +
    "<span class='d'>(#{ @ex_platform}, #{ @ex_physical ? 'Physical' : 'Digital'})</span> -> " +
    "<span class='d'>(#{ @game.platform_name}, #{ @game.physical ? 'Physical' : 'Digital'})</span>"
  end
end
