defmodule XenAPI.Common do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def get_all(xapi), do: XenClient.session_method_call(xapi, "#{@resource}.get_all")
      def get_all_records(xapi), do: XenClient.session_method_call(xapi, "#{@resource}.get_all_records")
      def get_record(xapi, ref_object), do: XenClient.session_method_call(xapi, "#{@resource}.get_record", [ref_object])
      def get_by_uuid(xapi, uuid), do: XenClient.session_method_call(xapi, "#{@resource}.get_by_uuid", [uuid])
      def get_by_name_label(xapi, name_label), do: XenClient.session_method_call(xapi, "#{@resource}.get_by_name_label", [name_label])
    end
  end
end
