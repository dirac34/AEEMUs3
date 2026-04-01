#!/usr/bin/env bash
# run_paper_experiments.sh
# Orden correcto:
#   1. Filter Ablation  -> determina la mejor configuración de filtros por dataset
#   2. SOTA Comparison  -> usa automáticamente la mejor config encontrada en paso 1
#   3. Filter Ordering  -> ablación del orden de aplicación de filtros
#   4. Figuras          -> genera todas las figuras del paper
#
# Uso: bash run_paper_experiments.sh
# En background: nohup bash run_paper_experiments.sh > experimentos.log 2>&1 &

set -e
cd "/root/proyectos/AEEMU GPU OPTIMIZED/Code"
source AEEMU/bin/activate

FOLDS=5
RESULTS_DIR="/root/proyectos/AEEMU GPU OPTIMIZED/Code/results"
FIGURES_DIR="/root/proyectos/AEEMU GPU OPTIMIZED/Code/paper_figures"
DATASETS=("ml-100k" "amazon-music" "book-crossing" "jester")

mkdir -p "$RESULTS_DIR" "$FIGURES_DIR"

echo "======================================================"
echo "  STEP 1/4: Filter Ablation (4 datasets, $FOLDS folds)"
echo "  Determina la mejor configuracion de filtros de cada"
echo "  dataset antes de ejecutar la comparacion SOTA."
echo "======================================================"
for DS in "${DATASETS[@]}"; do
    echo ""
    echo ">>> Filter Ablation: $DS"
    python AEEMU_Filtering_v2.py --filter-ablation --dataset "$DS" --folds $FOLDS
done

echo ""
echo "======================================================"
echo "  STEP 2/4: SOTA Comparison (4 datasets, $FOLDS folds)"
echo "  Usa automaticamente la mejor config hallada en step 1"
echo "  (best_from_ablation). Si no existe JSON de ablacion,"
echo "  usa best_three = {kalman, adaptive, ema} como fallback."
echo "======================================================"
for DS in "${DATASETS[@]}"; do
    echo ""
    echo ">>> SOTA: $DS"
    python AEEMU_Filtering_v2.py --sota-full --dataset "$DS" --folds $FOLDS
done

echo ""
echo "======================================================"
echo "  STEP 3/4: Filter Ordering Ablation (2 datasets)"
echo "  Responde Reviewer #3.2: importa el orden de filtros?"
echo "======================================================"
for DS in "ml-100k" "amazon-music"; do
    echo ""
    echo ">>> Filter Ordering: $DS"
    python AEEMU_Filtering_v2.py --filter-ordering --dataset "$DS" --folds $FOLDS
done

echo ""
echo "======================================================"
echo "  STEP 4/4: Generando figuras del paper"
echo "======================================================"
python generate_figures.py \
    --results-dir "$RESULTS_DIR" \
    --output-dir "$FIGURES_DIR"

echo ""
echo "✅ Todos los experimentos completados."
echo "   Figuras en:     $FIGURES_DIR"
echo "   Resultados en:  $RESULTS_DIR"