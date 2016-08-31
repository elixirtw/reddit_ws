defmodule RedditWs.PageController do
  use RedditWs.Web, :controller

  @reddit_url "https://www.reddit.com"
  @post_limit 15

  def index(conn, params) do
    post_titles = fetch(params["subreddit"])
    render conn, "index.html", post_titles: post_titles, subreddit: params["subreddit"]
  end

  # This belongs somewhere else
  defp fetch(nil), do: []
  defp fetch(subreddit) do
    "#{@reddit_url}/r/#{subreddit}.json?limit=#{@post_limit}"
    |> HTTPotion.get([timeout: 15_000])
    |> handle_response
    |> decode_response
  end

  defp handle_response(%{status_code: 200, body: body, headers: _}) do
    Poison.Parser.parse!(body)
  end

  defp handle_response(_) do
    raise "OH NO!"
  end

  defp decode_response(%{"data" => %{ "children" => posts}}) do
    posts
    |> Enum.map( fn(%{"data" => %{"title" => title}}) -> title end)
  end
end
