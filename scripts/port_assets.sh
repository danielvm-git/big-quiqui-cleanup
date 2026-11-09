#!/usr/bin/env bash
# Copies the planned art and audio from big-quiqui-v2 once, with English names (BACKLOG: planned ports).
#   bash scripts/port_assets.sh [path-to-v2-game]
set -euo pipefail
SRC="${1:-$HOME/Developer/big-quiqui-v2/game}/assets"
DST="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/game/assets"

copy() {
	local from="$1" to="$2"
	mkdir -p "$DST/$(dirname "$to")"
	cp "$SRC/$from" "$DST/$to"
}

copy art/backgrounds/bg_sala.jpg art/backgrounds/living_room.jpg
copy art/items/esponja.png art/items/sponge.png
copy art/items/bola.png art/items/ball.png
copy art/items/pelucia.png art/items/plush.png
copy art/items/patinho.png art/items/toy_duck.png
copy art/items/saquinho_lixo.png art/items/trash_bag.png
copy art/efeitos/brilho.png art/effects/sparkle.png
copy art/efeitos/espuma_media.png art/effects/foam.png
copy art/efeitos/bolha.png art/effects/bubble.png
copy art/quiqui/quiqui_base.png art/quiqui/idle.png
copy art/quiqui/quiqui_pulando.png art/quiqui/jump.png
copy art/quiqui/quiqui_rindo.png art/quiqui/laugh.png
copy art/quiqui/quiqui_acenando.png art/quiqui/wave.png
copy art/quiqui/quiqui_brilhando.png art/quiqui/sparkle.png
copy art/ui/botao_casa.png art/ui/home_button.png
copy art/ui/botao_play.png art/ui/play_button.png
copy art/ui/bolinha_progresso.png art/ui/dot_full.png
copy art/ui/bolinha_progresso_vazia.png art/ui/dot_empty.png
copy audio/sfx/tap.ogg audio/sfx/tap.ogg
copy audio/sfx/success.ogg audio/sfx/success.ogg
copy audio/sfx/drop.ogg audio/sfx/drop.ogg
copy audio/sfx/erro_suave.ogg audio/sfx/soft_miss.ogg
copy audio/sfx/bolha.ogg audio/sfx/bubble.ogg
copy audio/sfx/select.ogg audio/sfx/select.ogg
copy audio/music/tema_principal.ogg audio/music/main_theme.ogg
echo "assets copied to $DST"
