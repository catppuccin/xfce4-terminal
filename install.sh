#!/bin/bash

# set -eux
declare -A color_schemes=(
  ["frappe"]="#F2D5CF #232634 false #C6D0F5 #303446 #626880 #C6D0F5 false #EF9F76 #51576D;#E78284;#A6D189;#E5C890;#8CAAEE;#F4B8E4;#81C8BE;#B5BFE2;#626880;#E78284;#A6D189;#E5C890;#8CAAEE;#F4B8E4;#81C8BE;#A5ADCE"
  ["latte"]="#DC8A78 #EFF1F5 false #4C4F69 #EFF1F5 #ACB0BE #4C4F69 false #FE640B #5C5F77;#D20F39;#40A02B;#DF8E1D;#1E66F5;#EA76CB;#179299;#ACB0BE;#6C6F85;#D20F39;#40A02B;#DF8E1D;#1E66F5;#EA76CB;#179299;#BCC0CC"
  ["macchiato"]="#F4DBD6 #181926 false #CAD3F5 #24273A #5B6078 #CAD3F5 false #F5A97F #494D64;#ED8796;#A6DA95;#EED49F;#8AADF4;#F5BDE6;#8BD5CA;#B8C0E0;#5B6078;#ED8796;#A6DA95;#EED49F;#8AADF4;#F5BDE6;#8BD5CA;#A5ADCB"
  ["mocha"]="#F5E0DC #11111B false #CDD6F4 #1E1E2E #585B70 #CDD6F4 false #FAB387 #45475A;#F38BA8;#A6E3A1;#F9E2AF;#89B4FA;#F5C2E7;#94E2D5;#BAC2DE;#585B70;#F38BA8;#A6E3A1;#F9E2AF;#89B4FA;#F5C2E7;#94E2D5;#A6ADC8"
)

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

function display_flavors() {
  echo "Available flavors:"
  index=1
  for flavor in "${!color_schemes[@]}"; do
    echo "$index - $flavor"
    ((index++))
  done
  echo "5 - all"
}

function import_preset() {
  local chosen_flavor="$1"
  local src_dir=~/.local/share/xfce4/terminal/colorschemes
  local src_url=https://raw.githubusercontent.com/catppuccin/xfce4-terminal/main/src/catppuccin-${chosen_flavor}.theme
  local filename
  filename=$(basename "$src_url")

  [[ -d "$src_dir" ]] || mkdir -p "$src_dir"

  echo -e "Downloading/Importing preset from the source..."
  if command -v curl &>/dev/null; then
    curl -sL "$src_url" >"$src_dir/$filename"
  elif command -v wget &>/dev/null; then
    wget -qO- "$src_url" >"$src_dir/$filename"
  fi

  if [[ -f "$src_dir/$filename" ]]; then
    echo "Preset: 'Catppuccin-$chosen_flavor' are imported successfully."
  else
    echo "Error: Unable to import the theme for 'Catppuccin-$chosen_flavor'."
  fi
}

function set_color_scheme() {
  if command -v xfconf-query &>/dev/null; then
    local chosen_flavor="$1"
    IFS=' ' read -r -a colors <<<"${color_schemes[$chosen_flavor]}"
    xfconf-query --channel xfce4-terminal --property /color-cursor --set "${colors[0]}"
    xfconf-query --channel xfce4-terminal --property /color-cursor-foreground --set "${colors[1]}"
    xfconf-query --channel xfce4-terminal --property /color-cursor-use-default --set "${colors[2]}"
    xfconf-query --channel xfce4-terminal --property /color-foreground --set "${colors[3]}"
    xfconf-query --channel xfce4-terminal --property /color-background --set "${colors[4]}"
    xfconf-query --channel xfce4-terminal --property /color-selection-background --set "${colors[5]}"
    xfconf-query --channel xfce4-terminal --property /color-selection --set "${colors[6]}"
    xfconf-query --channel xfce4-terminal --property /color-selection-use-default --set "${colors[7]}"
    xfconf-query --channel xfce4-terminal --property /tab-activity-color --set "${colors[8]}"
    xfconf-query --channel xfce4-terminal --property /color-palette --set "${colors[9]}"
  else
    echo -e "Goto Preferences → Colors → Presets to apply the theme.\n"
  fi
}

function main() {
  ascii_art && sleep 1
  display_flavors
  echo && read -rp "Choose flavor from num[1-5]: " chosen_flavor && echo

  if ((chosen_flavor >= 1 && chosen_flavor <= ${#color_schemes[@]})); then
    # Options 1-4: Import a specific chosen flavor
    index=1
    for flavor in "${!color_schemes[@]}"; do
      if ((index == chosen_flavor)); then
        import_preset "$flavor"
        set_color_scheme "$flavor"
        break
      fi
      ((index++))
    done
  elif ((chosen_flavor == 5)); then
    # Option 5: Import all presets
    for flavor in "${!color_schemes[@]}"; do
      import_preset "$flavor"
      set_color_scheme "$flavor"
    done
  else
    echo "Error: Invalid choice."
  fi
}

main
