defmodule Rumbl.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rumbl.Accounts.Credential

  schema "users" do
    field :name, :string
    field :username, :string
    has_one :credential, Credential

    timestamps()
  end

  @doc """
  Accepts an Accounts.User struct and some attributes, returns Account.User.


  Changesets are for checking errors and enforcing limits without even touching the database first.
  So by casting we make sure only keys on our schema are used, and also that any invalid ones will throw an error.
  By changing the changeset with things like `validate_required()` we are doing the same thing, making the changeset invalid if there is no `:name` key for example.

  `validate_required()` will take a changeset and return one, so you can pipe as many requirements on that changeset as you like.

  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :username])
    |> validate_required([:name, :username])
    |> validate_length(:username, min: 1, max: 20)
    |> unique_constraint(:username)
  end

  @doc """
  Since we’re changing a structure that has elements in two tables,
   we need Ecto.Changeset.cast_assoc. Its job is to help a single changeset
  successfully navigate the relationship between User and Credential. We give Ecto
  the information it needs for this association with the has_one relationship.
  """
  def registration_changeset(user, params) do
    user
    |> changeset(params)
    |> cast_assoc(:credential, with: &Credential.changeset/2, required: true)
  end
end
