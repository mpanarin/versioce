defmodule VersioceTest.Bumper do
  use ExUnit.Case, async: true
  alias Versioce.Bumper

  defp test_versioning(binding, new_vers) do
    vers = "0.1.0"
    assert Bumper.bump([binding], vers) == new_vers
  end

  defp test_build_pre(binding, new_vers) do
    vers = "0.1.0"
    assert Bumper.bump([binding, "--pre", "alpha"], vers) == new_vers <> "-alpha"
    assert Bumper.bump([binding, "--pre", "alpha.3.spam-eggs"], vers) == new_vers <> "-alpha.3.spam-eggs"

    assert Bumper.bump([binding, "--build", "foo"], vers) == new_vers <> "+foo"
    assert Bumper.bump([binding, "--build", "foo.3.spam-eggs"], vers) == new_vers <> "+foo.3.spam-eggs"
    assert Bumper.bump([binding, "--build", "bar.50-6"], vers) == new_vers <> "+bar.50-6"

    assert Bumper.bump([binding, "--pre", "alpha", "--build", "foo"], vers) == new_vers <>"-alpha+foo"
    assert Bumper.bump([binding, "--pre", "alpha.1.test-test", "--build", "foo.1.-bar"], vers) == new_vers <>"-alpha.1.test-test+foo.1.-bar"

    assert_raise Version.InvalidVersionError, fn ->
      Bumper.bump([binding, "--build", "foo[]"], vers)
    end
    assert_raise Version.InvalidVersionError, fn ->
      Bumper.bump([binding, "--pre", "foo[]"], vers)
    end
  end

  setup do
    %{
      current_version: Mix.Project.config()[:version]
    }
  end

  test "Proper current version is returned", fixture do
    assert Bumper.current_version() == {:ok, fixture.current_version}
  end

  describe "Test version bumping:" do

    test "Nothing specified" do
      assert Bumper.bump([], "0.1.0") == "0.1.0"
    end

    test "Bump with patch" do
      test_versioning("patch", "0.1.1")
      test_build_pre("patch", "0.1.1")
    end

    test "Bump with minor" do
      test_versioning("minor", "0.2.0")
      test_build_pre("minor", "0.2.0")
    end
    test "Bump with major" do
      test_versioning("major", "1.0.0")
      test_build_pre("major", "1.0.0")
    end

    test "Bump to specific" do
      vers = "0.1.0"
      assert Bumper.bump(["2.3.3"], vers) == "2.3.3"

      assert Bumper.bump(["2.3.3-foo"], vers) == "2.3.3-foo"
      assert Bumper.bump(["2.3.3+bar"], vers) == "2.3.3+bar"
      assert Bumper.bump(["2.3.3-foo+bar"], vers) == "2.3.3-foo+bar"
      assert Bumper.bump(["2.3.3-foo.3-1+bar.50-6"], vers) == "2.3.3-foo.3-1+bar50-6"

      assert_raise Version.InvalidVersionError, fn ->
        Bumper.bump(["2.3.3-foo[]"], vers)
      end
    end

    test "Only adding pre or build" do
      vers = "0.1.0"
      assert Bumper.bump(["--pre", "foo"], vers) == vers <> "-foo"
      assert Bumper.bump(["--build", "foo"], vers) == vers <> "+foo"
      assert Bumper.bump(["--pre", "foo", "--build", "bar"], vers) == vers <> "-foo+bar"
    end
  end
end
