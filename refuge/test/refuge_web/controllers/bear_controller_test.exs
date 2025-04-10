defmodule RefugeWeb.BearControllerTest do
  use RefugeWeb.ConnCase

  alias Refuge.Wildthings

  @create_attrs %{name: "some name", type: "some type", hibernating: true}
  @update_attrs %{name: "some updated name", type: "some updated type", hibernating: false}
  @invalid_attrs %{name: nil, type: nil, hibernating: nil}

  def fixture(:bear) do
    {:ok, bear} = Wildthings.create_bear(@create_attrs)
    bear
  end

  describe "index" do
    test "lists all bears", %{conn: conn} do
      conn = get(conn, Routes.bear_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Bears"
    end
  end

  describe "new bear" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.bear_path(conn, :new))
      assert html_response(conn, 200) =~ "New Bear"
    end
  end

  describe "create bear" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.bear_path(conn, :create), bear: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.bear_path(conn, :show, id)

      conn = get(conn, Routes.bear_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Bear"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.bear_path(conn, :create), bear: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Bear"
    end
  end

  describe "edit bear" do
    setup [:create_bear]

    test "renders form for editing chosen bear", %{conn: conn, bear: bear} do
      conn = get(conn, Routes.bear_path(conn, :edit, bear))
      assert html_response(conn, 200) =~ "Edit Bear"
    end
  end

  describe "update bear" do
    setup [:create_bear]

    test "redirects when data is valid", %{conn: conn, bear: bear} do
      conn = put(conn, Routes.bear_path(conn, :update, bear), bear: @update_attrs)
      assert redirected_to(conn) == Routes.bear_path(conn, :show, bear)

      conn = get(conn, Routes.bear_path(conn, :show, bear))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, bear: bear} do
      conn = put(conn, Routes.bear_path(conn, :update, bear), bear: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Bear"
    end
  end

  describe "delete bear" do
    setup [:create_bear]

    test "deletes chosen bear", %{conn: conn, bear: bear} do
      conn = delete(conn, Routes.bear_path(conn, :delete, bear))
      assert redirected_to(conn) == Routes.bear_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.bear_path(conn, :show, bear))
      end
    end
  end

  defp create_bear(_) do
    bear = fixture(:bear)
    %{bear: bear}
  end
end
