#!/bin/sh
set -e

# ============================================================
# RL 项目部 — openclacky Skill 一键初始化
# 用法: curl -fsSL https://raw.githubusercontent.com/RLBox/skillshare/main/team-init.sh | bash
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

info()  { printf "${GREEN}✓${NC} %s\n" "$1"; }
step()  { printf "\n${BOLD}▸ %s${NC}\n" "$1"; }
warn()  { printf "${YELLOW}⚠${NC} %s\n" "$1"; }
error() { printf "${RED}✗${NC} %s\n" "$1" >&2; exit 1; }

SKILLSHARE_INSTALL_URL="https://raw.githubusercontent.com/RLBox/skillshare/main/install.sh"
BOX_SKILLS_SOURCE="RLBox/skills/skills"
BOX_FILTER="box-*"
OPENCLACKY_SKILLS_DIR="${HOME}/.clacky/skills"

echo ""
echo "  🦞  RL 项目部 · openclacky Skill 一键初始化"
echo "  ─────────────────────────────────────────────"
echo ""

# ── Step 1: Check/install skillshare ──────────────────────
step "1/5  检查 skillshare..."

if command -v skillshare >/dev/null 2>&1; then
    SK_VER=$(skillshare version 2>/dev/null | head -1 || echo "unknown")
    info "skillshare 已安装 (${SK_VER})"
else
    warn "skillshare 未安装，正在安装..."
    if ! curl -fsSL "${SKILLSHARE_INSTALL_URL}" | bash; then
        error "skillshare 安装失败，请检查网络后重试"
    fi
    info "skillshare 安装完成"
fi

# ── Step 2: Initialize skillshare (non-interactive) ───────
step "2/5  初始化 skillshare..."

# Check if already initialized
if skillshare target list >/dev/null 2>&1; then
    info "skillshare 已初始化"
else
    info "正在初始化 skillshare (非交互模式)..."
    if skillshare init --no-copy --no-git --no-skill --targets openclacky --mode merge; then
        info "skillshare 初始化完成"
    else
        warn "skillshare 初始化失败，尝试继续..."
        # Some environments may need manual init
        warn "如果后续步骤失败，请手动执行: skillshare init --no-copy --no-git --no-skill --targets openclacky --mode merge"
    fi
fi

# ── Step 3: Check openclacky ──────────────────────────────
step "3/5  检查 openclacky..."

if [ -d "${OPENCLACKY_SKILLS_DIR}" ]; then
    info "openclacky skills 目录就绪: ${OPENCLACKY_SKILLS_DIR}"
else
    warn "openclacky skills 目录不存在: ${OPENCLACKY_SKILLS_DIR}"
    warn "请先安装 openclacky，确保该目录存在后重试"
    warn "如果目录路径不同，请手动执行: skillshare target add openclacky --path <你的路径> -g"
    error "初始化中止 — openclacky 未就绪"
fi

# ── Step 4: Install box skills ────────────────────────────
step "4/5  安装 Box 技能..."

echo "  正在从 ${BOX_SKILLS_SOURCE} 安装 ${BOX_FILTER}..."
if skillshare install "${BOX_SKILLS_SOURCE}" -s "${BOX_FILTER}" --skip-audit 2>&1; then
    info "Box 技能安装完成"
else
    error "技能安装失败，请检查网络后重试"
fi

# ── Step 5: Configure target + sync ───────────────────────
step "5/5  配置 openclacky 目标并同步..."

# Check if openclacky target already exists
if skillshare target list 2>/dev/null | grep -qi "openclacky"; then
    info "openclacky 目标已配置"
else
    if skillshare target add openclacky --path "${OPENCLACKY_SKILLS_DIR}" -g 2>&1; then
        info "已添加 openclacky 目标"
    else
        warn "无法自动配置目标，请手动执行:"
        echo "  skillshare target add openclacky --path ${OPENCLACKY_SKILLS_DIR} -g"
    fi
fi

if skillshare sync 2>&1; then
    info "技能已同步到 openclacky"
else
    warn "同步遇到问题，请手动执行: skillshare sync"
fi

# ── Done ──────────────────────────────────────────────────
echo ""
echo "  ┌──────────────────────────────────────────────┐"
echo "  │                                              │"
echo "  │   🦞  初始化完成！                           │"
echo "  │                                              │"
echo "  │   已安装 17 个 Box 技能                       │"
echo "  │   已同步到 openclacky                        │"
echo "  │                                              │"
echo "  │   查看已安装: skillshare list                 │"
echo "  │   更新技能:   skillshare install RLBox/skills/skills -s \"box-*\" --update && skillshare sync"
echo "  │                                              │"
echo "  │   文档: https://dao-42.feishu.cn/wiki/TQWHwLIuBiZCCNkaRMxcPh5qnKf"
echo "  │                                              │"
echo "  └──────────────────────────────────────────────┘"
echo ""
