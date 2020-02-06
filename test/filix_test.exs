defmodule FilixTest do
  use ExUnit.Case
  doctest Filix

  describe "boundary validation" do

    test "upload requests return errors without required parameters" do

    end

    test "valid parameters return a request upload command" do
      {:ok, cmd} = result = Filix.request_upload(
        name: "test file",
        size: 9000,
        type: "JPG",
        tags: ["images", "test"],
      )

      assert cmd.upload_id != nil
    end

  end

  describe "filix applications" do

    test "we can start a filix application by name configuring default adapters for use" do

    end

    test "we can override adapters when requesting an upload" do

    end

    test "filix applications can be dispatched request upload commands for signed urls" do

    end

  end
end
