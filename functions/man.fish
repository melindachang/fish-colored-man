function man --wraps man --description 'Format and display manual pages'
    function _man_colorize -a var
        set -l caps $argv[2..]

        if set -q $var
            echo (set_color $var)
            return
        end

        echo -n (tput setaf $caps[1])

        for cap in $caps[2..]
            echo -n (tput $cap)
        end

        echo
    end

    set -l blink (_man_colorize man_blink 1 bold) # COLOR_RED
    set -l bold (_man_colorize man_bold 6 bold) # COLOR_CYAN
    set -l standout (_man_colorize man_standout 7) # COLOR_WHITE
    set -l underline (_man_colorize man_underline 5 smul) # COLOR_MAGENTA

    set -l end (printf "\e[0m")

    set -lx LESS_TERMCAP_mb $blink
    set -lx LESS_TERMCAP_md $bold
    set -lx LESS_TERMCAP_me $end
    set -lx LESS_TERMCAP_so $standout
    set -lx LESS_TERMCAP_se $end
    set -lx LESS_TERMCAP_us $underline
    set -lx LESS_TERMCAP_ue $end
    set -lx LESS '-R -s'

    set -lx GROFF_NO_SGR yes # fedora

    set -lx MANPATH (string join : $MANPATH)
    if test -z "$MANPATH"
        type -q manpath
        and set MANPATH (command manpath)
    end

    # Check data dir for Fish 2.x compatibility
    set -l fish_data_dir
    if set -q __fish_data_dir
        set fish_data_dir $__fish_data_dir
    else
        set fish_data_dir $__fish_datadir
    end

    set -l fish_manpath (dirname $fish_data_dir)/fish/man
    if test -d "$fish_manpath" -a -n "$MANPATH"
        set MANPATH "$fish_manpath":$MANPATH
        command man $argv
        return
    end
    command man $argv
end
