defmodule Servy.Conv do
  defstruct method: "",
            path: "",
            params: %{},
            headers: %{},
            resp_body: "",
            resp_status: nil


  @spec full_status(any()) :: nonempty_binary()
  def full_status(conv) do
    "#{conv.resp_status} #{status_reason(conv.resp_status)}"
  end


  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

end
