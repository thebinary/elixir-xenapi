defmodule XenAPI.Common do
  @moduledoc false

  defmacro __using__([resource: resource]) do
    quote location: :keep, bind_quoted: [resource: resource] do
      @doc """
      Get all object references
      """
      def get_all(xen_session), do: XenClient.session_method_call(xen_session, unquote("#{resource}.get_all"))

      @doc """
      Get all full records
      """
      def get_all_records(xen_session), do: XenClient.session_method_call(xen_session, unquote("#{resource}.get_all_records"))

      @doc """
      Get record for given `object-ref`
      """
      def get_record(xen_session, ref_object), do: XenClient.session_method_call(xen_session, unquote("#{resource}.get_record"), [ref_object])

      @doc """
      Get object ref for given `uuid`
      """
      def get_by_uuid(xen_session, uuid), do: XenClient.session_method_call(xen_session, unquote("#{resource}.get_by_uuid"), [uuid])

      @doc """
      Get object references for given `name_label`
      """
      def get_by_name_label(xen_session, name_label), do: XenClient.session_method_call(xen_session, unquote("#{resource}.get_by_name_label"), [name_label])
    end
  end
end
