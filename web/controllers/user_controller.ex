defmodule Rumbl.UserController do
    use Rumbl.Web, :controller
    plug :authenticate when action in [:index, :show]
    alias Rumbl.User


    def index(conn, _params) do
        users = Repo.all(User)
        render conn, "index.html", users: users
    end

    def show(conn, %{"id" => id}) do
        user = Repo.get(User, id)
        render conn, "show.html", user: user
    end

    def new(conn, _params) do
        changeset = User.changeset(%User{})
        render conn, "new.html", changeset: changeset
    end

    def create(conn, %{"user" => user_params}) do
        changeset = User.registration_changeset(%User{}, user_params)

        case Repo.insert(changeset) do
            {:ok, user} ->
                conn
                |> Rumbl.Auth.login(user) 
                |> put_flash(:info, "#{user.name} created!")
                |> redirect(to: user_path(conn, :index))
            {:error, changeset} ->
                render(conn, "new.html", changeset: changeset)
        end
    end

    def edit(conn,  %{"id" => id}) do
        user = Repo.get!(User, id)
        changeset = User.changeset(user)
        render conn, "edit.html", user: user, changeset: changeset
    end

    def update(conn, %{"id" => id, "user" => user_params}) do
        user = Repo.get!(User, id)
        changeset = User.changeset(user, user_params)

        case Repo.update(changeset) do
            {:ok, user} ->
                conn
                |> put_flash(:info, "#{user.name} updated!")
                |> redirect(to: user_path(conn, :index))
            {:error, changeset, user} ->
                render(conn, "edit.html", user: user, changeset: changeset)
        end
    end

    def delete(conn, %{"id" => id}) do
        user = Repo.get!(User, id)

        Repo.delete(user)
        conn
        |> put_flash(:info, "#{user.name} deleted!")
        |> redirect(to: user_path(conn, :index))

    end

    defp authenticate(conn, _opts) do
        if conn.assigns.current_user do
            conn
        else
            conn
            |> put_flash(:error, "You must be logged in to access that page")
            |> redirect(to: page_path(conn, :index))
            |> halt()
        end
    end

end
