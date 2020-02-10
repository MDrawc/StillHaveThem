class AddPlatform < ApplicationService
  def initialize(user:, platform_id:, platform_name:)
    @user = user
    @id = platform_id
    @name = platform_name
  end

  def call
    unless user_have_platform
      unless find_the_same_platform
        create_the_platform
      end
      add_the_platform
    end
  end

  private
    def user_have_platform
      @user.platforms.find_by(igdb_id: @id)
    end

    def find_the_same_platform
      @new_platform = Platform.find_by(igdb_id: @id)
    end

    def create_the_platform
      @new_platform = Platform.create(igdb_id: @id, name: @name)
    end

    def add_the_platform
      @user.platforms << @new_platform
    end
end
