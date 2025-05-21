defmodule VersioceTest.Bumper do
  use ExUnit.Case, async: true
  alias Mix.Tasks.Bump
  alias Versioce.Bumper
  import ExUnit.CaptureIO
  use Mimic

  defp helper_bump(options, version) do
    options = options
    |> Bump.parse()

    new_version = Bumper.get_new_version(options, version)

    Bumper.bump(version, new_version)
  end

  defp test_versioning(binding, new_vers) do
    vers = "0.1.0"
    assert helper_bump([binding], vers) == new_vers
  end

  defp test_build_pre(binding, new_vers) do
    vers = "0.1.0"
    assert helper_bump([binding, "--pre", "alpha"], vers) == new_vers <> "-alpha"

    assert helper_bump([binding, "--pre", "alpha.3.spam-eggs"], vers) ==
             new_vers <> "-alpha.3.spam-eggs"

    assert helper_bump([binding, "--build", "foo"], vers) == new_vers <> "+foo"

    assert helper_bump([binding, "--build", "foo.3.spam-eggs"], vers) ==
             new_vers <> "+foo.3.spam-eggs"

    assert helper_bump([binding, "--build", "bar.50-6"], vers) == new_vers <> "+bar.50-6"

    assert helper_bump([binding, "--pre", "alpha", "--build", "foo"], vers) ==
             new_vers <> "-alpha+foo"

    assert helper_bump([binding, "--pre", "alpha.1.test-test", "--build", "foo.1.-bar"], vers) ==
             new_vers <> "-alpha.1.test-test+foo.1.-bar"

    assert_raise Version.InvalidVersionError, fn ->
      helper_bump([binding, "--build", "foo[]"], vers)
    end

    assert_raise Version.InvalidVersionError, fn ->
      helper_bump([binding, "--pre", "foo[]"], vers)
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

  test "Proper current normal version is returned" do
    stub(Mix.Project, :config, fn -> %{version: "0.1.0-alpha+123.123"} end)

    assert Bumper.current_normal_version() == {:ok, "0.1.0"}
  end

  describe "Test version bumping:" do
    setup do
      Versioce.Bumper.Files
      |> stub(:update_version_files, fn _, _ -> :ok end)

      :ok
    end

    test "Nothing specified" do
      assert capture_io(fn ->
               assert helper_bump([], "0.1.0") == "0.1.0"
             end) == "Nothing to do\n"
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
      assert helper_bump(["2.3.3"], vers) == "2.3.3"

      assert helper_bump(["2.3.3-foo"], vers) == "2.3.3-foo"
      assert helper_bump(["2.3.3+bar"], vers) == "2.3.3+bar"
      assert helper_bump(["2.3.3-foo+bar"], vers) == "2.3.3-foo+bar"
      assert helper_bump(["2.3.3-foo.3-1+bar.50-6"], vers) == "2.3.3-foo.3-1+bar.50-6"

      assert_raise Version.InvalidVersionError, fn ->
        helper_bump(["2.3.3-foo[]"], vers)
      end
    end

    test "Only adding pre or build" do
      vers = "0.1.0"
      assert helper_bump(["--pre", "foo"], vers) == vers <> "-foo"
      assert helper_bump(["--build", "foo"], vers) == vers <> "+foo"
      assert helper_bump(["--pre", "foo", "--build", "bar"], vers) == vers <> "-foo+bar"
    end
  end
end
