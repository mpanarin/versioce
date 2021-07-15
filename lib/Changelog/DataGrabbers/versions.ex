defmodule Versioce.Changelog.DataGrabber.Versions do
  alias Versioce.Changelog.Sections

  @type t() :: [version()]
  @type version() :: %{
          version: String.t(),
          sections: Sections.t()
        }
end
