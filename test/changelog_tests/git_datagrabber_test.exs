defmodule ChangelogTests.Changelog.DataGrabber.Git do
  use ExUnit.Case, async: true
  use Mimic
  alias Versioce.Changelog.DataGrabber.Git, as: GitDatagrabber
  alias Versioce.Changelog.DataGrabber.Version
  alias Versioce.Changelog.Sections

  setup do
    stub_with(Versioce.Git, Versioce.Test.FakeRepository)
    :ok
  end

  describe "get_version/1" do
    test "gets proper HEAD version" do
      assert {:ok,
              %Version{
                sections: %Sections{
                  added: [":sparkles: unreleased change"],
                  changed: [],
                  deprecated: [],
                  fixed: [],
                  other: [],
                  removed: [],
                  security: []
                },
                version: "HEAD"
              }} = GitDatagrabber.get_version()
    end

    test "gets proper specific version" do
      assert {:ok,
              %Version{
                sections: %Sections{
                  added: [],
                  changed: [],
                  deprecated: [],
                  fixed: [":bug: bug fixed"],
                  other: [],
                  removed: [":coffin: dead code dropped"],
                  security: [":rotating_light: security upgraded"]
                },
                version: "v1.0.0"
              }} = GitDatagrabber.get_version("1.0.0")

      assert {:ok,
              %Version{
                sections: %Sections{
                  added: [
                    ":construction_worker: added CI",
                    ":construction: this is WIP",
                    ":art: improved formatting"
                  ],
                  changed: [],
                  deprecated: [],
                  fixed: [],
                  other: [],
                  removed: [],
                  security: []
                },
                version: "v0.0.2"
              }} = GitDatagrabber.get_version("0.0.2")
    end
  end

  describe "get_versions/1" do
    test "returns all versions properly for HEAD" do
      assert {:ok,
              [
                %Version{
                  sections: %Sections{
                    added: [":sparkles: unreleased change"],
                    changed: [],
                    deprecated: [],
                    fixed: [],
                    other: [],
                    removed: [],
                    security: []
                  },
                  version: "HEAD"
                },
                %Version{
                  sections: %Sections{
                    added: [],
                    changed: [],
                    deprecated: [],
                    fixed: [":bug: bug fixed"],
                    other: [],
                    removed: [":coffin: dead code dropped"],
                    security: [":rotating_light: security upgraded"]
                  },
                  version: "v1.0.0"
                },
                %Version{
                  sections: %Sections{
                    added: [],
                    changed: [
                      ":children_crossing: improved accessibility",
                      ":recycle: refactored some code"
                    ],
                    deprecated: [":gun: deprecated a feature"],
                    fixed: [],
                    other: [],
                    removed: [":fire: files removed"],
                    security: []
                  },
                  version: "v0.1.0"
                },
                %Version{
                  sections: %Sections{
                    added: [
                      ":construction_worker: added CI",
                      ":construction: this is WIP",
                      ":art: improved formatting"
                    ],
                    changed: [],
                    deprecated: [],
                    fixed: [],
                    other: [],
                    removed: [],
                    security: []
                  },
                  version: "v0.0.2"
                },
                %Version{
                  sections: %Sections{
                    added: [
                      ":sparkles: added new feature",
                      ":white_check_mark: added tests",
                      ":bulb: initial commit"
                    ],
                    changed: [],
                    deprecated: [],
                    fixed: [],
                    other: [],
                    removed: [],
                    security: []
                  },
                  version: "v0.0.1"
                }
              ]} = GitDatagrabber.get_versions()
    end

    test "returns all versions properly for specific version" do
      assert {:ok,
              [
                %Version{
                  sections: %Sections{
                    added: [":sparkles: unreleased change"],
                    changed: [],
                    deprecated: [],
                    fixed: [],
                    other: [],
                    removed: [],
                    security: []
                  },
                  version: "v1.0.1"
                },
                %Version{
                  sections: %Sections{
                    added: [],
                    changed: [],
                    deprecated: [],
                    fixed: [":bug: bug fixed"],
                    other: [],
                    removed: [":coffin: dead code dropped"],
                    security: [":rotating_light: security upgraded"]
                  },
                  version: "v1.0.0"
                },
                %Version{
                  sections: %Sections{
                    added: [],
                    changed: [
                      ":children_crossing: improved accessibility",
                      ":recycle: refactored some code"
                    ],
                    deprecated: [":gun: deprecated a feature"],
                    fixed: [],
                    other: [],
                    removed: [":fire: files removed"],
                    security: []
                  },
                  version: "v0.1.0"
                },
                %Version{
                  sections: %Sections{
                    added: [
                      ":construction_worker: added CI",
                      ":construction: this is WIP",
                      ":art: improved formatting"
                    ],
                    changed: [],
                    deprecated: [],
                    fixed: [],
                    other: [],
                    removed: [],
                    security: []
                  },
                  version: "v0.0.2"
                },
                %Version{
                  sections: %Sections{
                    added: [
                      ":sparkles: added new feature",
                      ":white_check_mark: added tests",
                      ":bulb: initial commit"
                    ],
                    changed: [],
                    deprecated: [],
                    fixed: [],
                    other: [],
                    removed: [],
                    security: []
                  },
                  version: "v0.0.1"
                }
              ]} = GitDatagrabber.get_versions("1.0.1")
    end
  end
end
