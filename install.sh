#!/usr/bin/env bash
# set -eux

function ascii_art() {
  cat <<"EOF"

   █▀▀ ▄▀█ ▀█▀ █▀█ █▀█ █░█ █▀▀ █▀▀ █ █▄░█
   █▄▄ █▀█ ░█░ █▀▀ █▀▀ █▄█ █▄▄ █▄▄ █ █░▀█
               𝕏𝔽ℂ𝔼𝟜-𝕋𝔼ℝ𝕄𝕀ℕ𝔸𝕃

                .;ldxxkkxo:.
            ':oxxxxxkOOOOOOOOdl,
         'lxxxxxxxkOOOOOOOO0KKKKKx,
       ;xxxxxxxxkOOOOOOOO0KKKkdOKKKO:
     'xxxo...':dOOOOOkkOKKx;....OK000k.
    :xxxxc......''..............l000000:
   :xxxxxd......................d00000OO,
  .xxxxkkO'........''......';,...l00Okkkk
  cxxkkOO,.......lkddxo...ll:co'..,kkkkkk;
  xkOOOOl........'.................ckkkkkd
  dOOOOO'...............lOd........,kkkOOl
  ,OOOOO'..............;;cl:'......:kOOOO.
   OOO0Kl...............'..........kOOOOx
    0KKKK:.......................,kOOOOO
     KKKKKx,...................;dOOOOOk
      :KKK00k;........'c;.;,..dOOOOOO'
        :000O.........,kkloc..:OOOO,
           xl.................,Oc
                ............

EOF
}

function apply_color_scheme() {
  local chosen_flavor="$1"
  local scheme_file="$2"

  # apply the chosen color scheme automatically, if no xfconf-query binary then print instructions.
  if command -v xfconf-query &>/dev/null; then
    color_cursor=$(echo "$scheme_file" | awk '/^ColorCursor=/ {split($0, a, "="); print a[2]}')
    color_cursor_fg=$(echo "$scheme_file" | awk '/^ColorCursorForeground=/ {split($0, a, "="); print a[2]}')
    color_cursor_default="false"
    color_fg=$(echo "$scheme_file" | awk '/^ColorForeground=/ {split($0, a, "="); print a[2]}')
    color_bg=$(echo "$scheme_file" | awk '/^ColorBackground=/ {split($0, a, "="); print a[2]}')
    color_selection_bg=$(echo "$scheme_file" | awk '/^ColorSelectionBackground=/ {split($0, a, "="); print a[2]}')
    color_selection=$(echo "$scheme_file" | awk '/^ColorSelection=/ {split($0, a, "="); print a[2]}')
    color_selection_default="false"
    tab_activity_color=$(echo "$scheme_file" | awk '/^TabActivityColor=/ {split($0, a, "="); print a[2]}')
    color_palette=$(echo "$scheme_file" | awk '/^ColorPalette=/ {split($0, a, "="); print a[2]}')
    # c = channel , n = new/create , t = type , p = property
    xfconf-query -c xfce4-terminal -n -t string -p /color-cursor --set "$color_cursor"
    xfconf-query -c xfce4-terminal -n -t string -p /color-cursor-foreground --set "$color_cursor_fg"
    xfconf-query -c xfce4-terminal -n -t string -p /color-cursor-use-default --set "$color_cursor_default"
    xfconf-query -c xfce4-terminal -n -t string -p /color-foreground --set "$color_fg"
    xfconf-query -c xfce4-terminal -n -t string -p /color-background --set "$color_bg"
    xfconf-query -c xfce4-terminal -n -t string -p /color-selection-background --set "$color_selection_bg"
    xfconf-query -c xfce4-terminal -n -t string -p /color-selection --set "$color_selection"
    xfconf-query -c xfce4-terminal -n -t string -p /color-selection-use-default --set "$color_selection_default"
    xfconf-query -c xfce4-terminal -n -t string -p /tab-activity-color --set "$tab_activity_color"
    xfconf-query -c xfce4-terminal -n -t string -p /color-palette --set "$color_palette"
  else
    echo -e "Goto Preferences → Colors → Presets to apply the theme.\n"
  fi
}

function fetch_color_presets() {
  local chosen_flavor="$1"
  local src_dir=~/.local/share/xfce4/terminal/colorschemes
  local src_url="https://raw.githubusercontent.com/catppuccin/xfce4-terminal/main/src/catppuccin-${chosen_flavor}.theme"
  local filename
  filename=$(basename "$src_url")

  [[ -d "$src_dir" ]] || mkdir -p "$src_dir"

  echo -e "Fetching preset from the source..."
  [[ -z "$(command -v curl || command -v wget)" ]] && {
    echo "Error: curl and wget command not found" && return 1
  }
  dl_cmd=$(command -v curl &>/dev/null && echo "curl -sL" || echo "wget -qO-")

  # download the preset colorscheme file and apply it
  local scheme_file
  scheme_file=$($dl_cmd "$src_url")
  echo "$scheme_file" >"$src_dir/$filename"
  apply_color_scheme "$chosen_flavor" "$scheme_file"

  if [[ -f "$src_dir/$filename" ]]; then
    echo -e "Preset: 'Catppuccin-$chosen_flavor' has been downloaded successfully.\n"
  else
    echo -e "Error: Unable to download the theme for 'Catppuccin-$chosen_flavor'.\n"
  fi
}

function main() {
  ascii_art && sleep 1
  echo && read -rp "Type the flavor name (frappe, latte, macchiato, mocha, all): " chosen_flavor && echo

  if [[ "$chosen_flavor" =~ ^(frappe|latte|macchiato|mocha)$ ]]; then
    fetch_color_presets "$chosen_flavor"
  elif [[ "$chosen_flavor" == "all" ]]; then
    for flavours in frappe latte macchiato mocha; do
      fetch_color_presets "$flavours"
    done
  else
    echo "Error: Invalid choice." && return 1
  fi
}

main
