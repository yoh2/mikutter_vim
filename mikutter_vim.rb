# vim: ts=2 sts=2 sw=2 et fileencoding=utf-8 :

require File.expand_path File.join(File.dirname(__FILE__), 'lib', 'simple_terminal_pane')

Plugin.create :vim do
  UserConfig[:vim_respawn] ||= false
  @saved_vim_panel = nil

  # コマンド定義
  command(:vim_open,
          name: 'Vimを開く',
          condition: lambda{ |opt| true },
          visible: true,
          role: :pane) do |opt|
    if Plugin::GUI::Tab.cuscaded.has_key?(:vim)
      Plugin::GUI::Tab.instance(:vim).active!
      next
    end
    vim_panel = SimpleTerminalPane.new(false)
    setup_terminal_pane vim_panel

    run_vim_on vim_panel.terminal

    tab(:vim, 'Vim') do
      # TODO: アイコン設定
      # 候補1: おなじみVIMアイコン
      # 候補2: Vim Girl
      # set_icon ...
      set_deletable true
      nativewidget vim_panel
      active!
    end
    @saved_vim_panel = vim_panel
  end

  # 設定項目
  settings 'Vim' do
    boolean '終了後に再度Vimを開く', :vim_respawn
  end

  # ターミナルペイン初期設定。
  def setup_terminal_pane(pane)
    # コマンド終了時の処理
    pane.terminal.signal_connect('child-exited') do |t|
      if UserConfig[:vim_respawn] then
        # もう一度起動
        run_vim_on t
      else
        # タブ削除
        # NOTE: 別の方法がありそうな気がする。
        Plugin::GUI::Tab.instance(:vim).destroy
      end
    end
  end

  # 指定したターミナル上でVimを起動する。
  def run_vim_on(terminal)
    terminal.fork_command(
      argv: [ "vim"],
      working_directory: ENV['HOME']
    )
  end

  on_gui_destroy do |gui|
    # タブ破棄時にSimpleTerminalPaneも破棄。
    # これをやらないとSimpleTerminalPaneどころか
    # 子プロセスまで残り続ける。
    # @saved_vim_panel など使わなくても、ここの引数から
    # 取得できそうな気がするが取得方法が分からない。
    puts gui
    if gui.slug == :vim && @saved_vim_panel != nil then
      @saved_vim_panel.destroy
      @saved_vim_panel = nil
    end
  end

end
