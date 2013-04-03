# vim: ts=2 sts=2 sw=2 et fileencoding=utf-8 :

require 'gtk2'
require 'vte'

class SimpleTerminalPane < Gtk::HBox
  def initialize(use_vscroll=true)
    super(false, 0)
    @use_vscroll = use_vscroll
    @terminal = Vte::Terminal.new
    @vscrollbar = Gtk::VScrollbar.new(@terminal.adjustment)
    add(@terminal)
    add(@vscrollbar) if use_vscroll
  end

  def active
    ancestor = get_ancestor(Gtk::Window)
    if ancestor then
      ancestor.set_focus(@terminal)
    end
  end

  attr_reader :terminal, :vscrollbar
end
