class CollectionsController < ApplicationController
before_action :require_user
before_action :correct_user, only: [:edit, :update, :destroy]
before_action :never_those, only: [:destroy]

def new
  @collection = Collection.new
end

def create
  @collection = current_user.collections.build(collection_params)
  @collection.name = @collection.custom_name

  if @collection.save
    flash[:success] = "Collection created"
    redirect_to root_url
  else
    render 'new'
  end
end

def edit
end

def update
  if @collection.update(collection_params)
    flash[:success] = 'Collection name changed'
    redirect_to root_url
  else
    render 'edit'
  end
end

def destroy
    @collection.destroy
    flash[:success] = "Collection deleted"
    redirect_to root_url
end

private

  def collection_params
    params.require(:collection).permit(:name, :default, :custom_name,
     :needs_platform)
  end

  def correct_user
    @collection = current_user.collections.find_by(id: params[:id])
    redirect_to root_url if @collection.nil?
  end

  def never_those
    @collection = current_user.collections.find_by(id: params[:id])
    if @collection.default
      flash[:danger] = "You can not delete this collection"
      redirect_to root_url
    end
  end
end
