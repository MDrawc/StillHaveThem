class ChangeDefaultValuesForArrays < ActiveRecord::Migration[5.2]
  def change
    change_column_default :queries, :results, nil

    change_column_default :games, :platforms, nil
    change_column_default :games, :developers, nil
    change_column_default :games, :screenshots, nil

    change_column_default :agames, :platforms, nil
    change_column_default :agames, :platforms_names, nil
    change_column_default :agames, :developers, nil
    change_column_default :agames, :screenshots, nil
  end
end
