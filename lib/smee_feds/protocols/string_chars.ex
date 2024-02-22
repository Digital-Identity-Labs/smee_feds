
defimpl String.Chars, for: SmeeFeds.Federation do
  @moduledoc false
  def to_string(s), do: "#[Federation #{s.uri}]"
end
