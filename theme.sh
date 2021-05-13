#!/bin/sh

# Written by Aetnaeus.
# Source: https://github.com/lemnos/theme.sh.
# Licensed under the WTFPL provided this notice is preserved.

# Find a broken theme? Want to add a missing one? PRs are welcome.
if ! [ -f .theme_cache ]
then
  echo "Building .theme_cache file, please wait..."
  for file in themes/*
  do
    echo "$file" | sed 's/themes\///' >> .theme_cache
    cat $file >> .theme_cache
    echo >> .theme_cache
  done
fi

themes="$(cat .theme_cache)"

# Use truecolor sequences to simulate the end result.
preview() {
	echo "$themes"| awk -F": " -v target="$1" '
		BEGIN {
			"tput cols" | getline nc
			"tput lines" | getline nr
			nc = int(nc)
			nr = int(nr)
		}

		function hextorgb(s) {
			hexchars = "0123456789abcdef"
			s = tolower(s)

			r = (index(hexchars, substr(s, 2, 1))-1)*16+(index(hexchars, substr(s, 3, 1))-1)
			g = (index(hexchars, substr(s, 4, 1))-1)*16+(index(hexchars, substr(s, 5, 1))-1)
			b = (index(hexchars, substr(s, 6, 1))-1)*16+(index(hexchars, substr(s, 7, 1))-1)
		}

		function fgesc(col) {
			hextorgb(col)
			return sprintf("\x1b[38;2;%d;%d;%dm", r, g, b)
		}

		function bgesc(col) {
			hextorgb(col)
			return sprintf("\x1b[48;2;%d;%d;%dm", r, g, b)
		}

		$0 == target {s++}

		s && /^foreground:/ { fg = $2 }
		s && /^background:/ { bg = $2 }
		s && /^[0-9]+:/ { a[$1] = $2 }

		/^ *$/ {s=0}

		function puts(s,   len,   i,   normesc,   filling) {
			normesc = sprintf("\x1b[0m%s%s", fgesc(fg), bgesc(bg))

			len=s
			gsub(/\033\[[^m]*m/, "", len)
			len=length(len)

			filling=""
			for(i=0;i<(nc-len);i++) filling=filling" "

			printf "%s%s%s%s\n", normesc, s, normesc, filling, ""
			nr--
		}

		END {
			puts("")
			for (i = 0;i<16;i++)
				puts(sprintf("  %s Color %d\x1b[0m", fgesc(a[i]), i))

			# Note: Some terminals use different colors for bolded text and may produce slightly different ls output.

			puts("")
			puts(" # ls --color -l")
			puts("    total 4")
			puts("    -rw-r--r-- 1 user user    0 Jan  0 02:39 file")
			puts(sprintf("    drwxr-xr-x 2 user user 4096 Jan  0 02:39 \x1b[1m%sdir/", fgesc(a[4])))
			puts(sprintf("    -rwxr-xr-x 1 user user    0 Jan  0 02:39 \x1b[1m%sexecutable", fgesc(a[10])))
			puts(sprintf("    lrwxrwxrwx 1 user user   15 Jan  0 02:40 \x1b[1m%ssymlink\x1b[0m%s%s -> /etc/symlink", fgesc(a[6]), fgesc(fg), bgesc(bg)))


			while(nr > 0) puts("")

			printf "\x1b[0m"
		}
	'
}

preview2() {
	printf '\033[30mColor 0\n'
	printf '\033[31mColor 1\n'
	printf '\033[32mColor 2\n'
	printf '\033[33mColor 3\n'
	printf '\033[34mColor 4\n'
	printf '\033[35mColor 5\n'
	printf '\033[36mColor 6\n'
	printf '\033[37mColor 7\n'

	printf '\033[90mColor 8\n'
	printf '\033[91mColor 9\n'
	printf '\033[92mColor 10\n'
	printf '\033[93mColor 11\n'
	printf '\033[94mColor 12\n'
	printf '\033[95mColor 13\n'
	printf '\033[96mColor 14\n'
	printf '\033[97mColor 15\n'

	printf '\n\033[0m'
	printf '# ls --color -lF\n'
	printf '    total 4\n'
	printf '    -rw-r--r-- 1 user user    0 Jan  0 02:39 file\n'
	printf '    drwxr-xr-x 2 user user 4096 Jan  0 02:39 \033[01;34mdir/\033[0m\n'
	printf '    -rwxr-xr-x 1 user user    0 Jan  0 02:39 \033[01;32mexecutable\033[0m*\n'
	printf '    lrwxrwxrwx 1 user user   15 Jan  0 02:40 \033[01;36msymlink\033[0m -> /etc/symlink\n'

	printf '\033[0m'
}

apply() {
	echo "$themes"| awk -F": " -v target="$1" '
		function tmuxesc(s) { return sprintf("\033Ptmux;\033%s\033\\", s) }
		function normalize_term() {
			# Term detection voodoo

			if(ENVIRON["TERM_PROGRAM"] == "iTerm.app")
				term="iterm"
			else if(ENVIRON["TMUX"]) {
				"tmux display-message -p \"#{client_termname}\"" | getline term
				is_tmux++
			} else
				term=ENVIRON["TERM"]
		}

		BEGIN {
			normalize_term()

			if(term == "iterm") {
				bgesc="\033]Ph%s\033\\"
				fgesc="\033]Pg%s\033\\"
				colesc="\033]P%x%s\033\\"
				curesc="\033]Pl%s\033\\"
			} else {
				#Terms that play nice :)

				fgesc="\033]10;#%s\007"
				bgesc="\033]11;#%s\007"
				curesc="\033]12;#%s\007"
				colesc="\033]4;%d;#%s\007"
			}

			if(is_tmux) {
				fgesc=tmuxesc(fgesc)
				bgesc=tmuxesc(bgesc)
				curesc=tmuxesc(curesc)
				colesc=tmuxesc(colesc)
			}
		}

		$0 == target {found++}

		found && /^foreground:/ {fg=$2}
		found && /^background:/ {bg=$2}
		found && /^[0-9]+:/ {colors[int($1)]=$2}
		found && /^cursorColor:/ {cursor=$2}

		found && /^ *$/ { exit }

		END {
			if(found) {
				for(c in colors)
					printf colesc, c, substr(colors[c], 2) > "/dev/tty"

				printf fgesc, substr(fg, 2) > "/dev/tty"
				printf bgesc, substr(bg, 2) > "/dev/tty"
				printf curesc, substr(cursor, 2) > "/dev/tty"

				f=ENVIRON["THEME_HISTFILE"]
				if(f) {
					while((getline < f) > 0)
						if($0 != target)
							out = out $0 "\n"
					close(f)

					out = out target
					print out > f
				}

        t=ENVIRON["THEME_SH_CURRENT_THEME"]
				if(t) {
          print target > t
          print "Foreground", substr(fg, 1) > t
          print "Background", substr(bg, 1) > t
          print "Cursor", substr(cursor, 1) > t
          for(c in colors)
            print c, substr(colors[c], 1) > t
				}
			}
		}
	'
}

list() {
	echo "$themes"| awk '
		BEGIN {
			f = ENVIRON["THEME_HISTFILE"]
			if(f) {
				while((getline < f) > 0) {
					mru[nmru++] = $0
					seen[$0] = 1
				}
			}

			s = 1
		}

		/^ *$/ { s=1; next }

		s {
			if(!seen[$0])
				print

			s = 0
		}

		END {
			for(i = 0;i < nmru;i++)
				print mru[i]
		}
	'
}

if [ -z "$1" ]; then
	echo "Usage: $(basename "$0") [-l|--list] [-i|--interactive] [-i2|--interactive2] [-r|--random] <theme>"
	exit
fi

case "$1" in
-i2|--interactive2)
	command -v fzf > /dev/null 2>&1 || { echo "ERROR: -i requires fzf" >&2; exit 1; }
	"$0" -l|fzf\
		--tac\
		--bind "enter:execute-silent($0 {})"\
		--bind "down:down+execute-silent(THEME_HISTFILE= $0 {})"\
		--bind "up:up+execute-silent(THEME_HISTFILE= $0 {})"\
		--bind "change:execute-silent(THEME_HISTFILE= $0 {})"\
		--bind "ctrl-c:execute($0 {};echo {})+abort"\
		--bind "esc:execute($0 {};echo {})+abort"\
		--no-sort\
		--preview "$0 --preview2"
	;;
-r|--random)
	theme=$($0 -l|sort -R|head -n1)
	$0 "$theme"
	echo "Theme: $theme"
	;;
-i|--interactive)
	command -v fzf > /dev/null 2>&1 || { echo "ERROR: -i requires fzf" >&2; exit 1; }
	if [ -z "$COLORTERM" ]; then
		echo "This does not appear to be a truecolor terminal, try -i2 instead or set COLORTERM if your terminal has truecolor support."
		exit 1
	else
		"$0" -l|fzf\
			--tac\
			--bind "ctrl-c:execute(echo {})+abort"\
			--bind "esc:execute(echo {})+abort"\
			--bind "enter:execute-silent($0 {})"\
			--no-sort\
			--preview "$0 --preview {}"
	fi
	;;
-l|--list)
	list
	;;
--preview2)
	preview2 "$2"
	;;
--preview)
	preview "$2"
	;;
*)
	apply "$1"
	;;
esac
