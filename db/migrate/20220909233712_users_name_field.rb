class UsersNameField < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :name, :string

    # Set each user's name to the email address username.
    User.find_each do |user|
      user.name = user.email[/^[^@]+/]
      user.save
    end

    # Make the new field required .
    change_column :users, :name, :string, null: false
  end
end
