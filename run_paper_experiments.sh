#!/usr/bin/env bash
# run_paper_experiments.sh
# Ejecuta todos los experimentos del paper (sin ml-1m), 5 folds
# Uso: bash run_paper_experiments.sh

set -e
cd /root/proyectos/AEEMU\ GPU\ OPTIMIZED/Code
source AEEMU/bin/activate

FOLDS=5
RESULTS_DIR="/root/proyectos/AEEMU GPU OPTIMIZED/Code/results"
FIGURES_DIR="/root/proyectos/AEEMU GPU OPTIMIZED/Code/paper_figures"
DATASETS=("ml-100k" "amazon-music" "book-crossing" "jester")

echo "======================================================"
echo "  STEP 1/3: SOTA Comparison (4 datasets, $FOLDS folds)"
echo "======================================================"
for DS in "${DATASETS[@]}"; do
    echo ""
    echo ">>> SOTA: $DS"
    python AEEMU_Filtering_v2.py --sota-full --dataset "$DS" --folds $FOLDS
done

echo ""
echo "======================================================"
echo "  STEP 2/3: Filter Ablation (4 datasets, $FOLDS folds)"
echo "======================================================"
for DS in "${DATASETS[@]}"; do
    echo ""
    echo ">>> Filter Ablation: $DS"
    python AEEMU_Filtering_v2.py --filter-ablation --dataset "$DS" --folds $FOLDS
done

echo ""
echo "======================================================"
echo "  STEP 3/3: Filter Ordering Ablation (2 datasets)"
echo "======================================================"
for DS in "ml-100k" "amazon-music"; do
    echo ""
    echo ">>> Filter Ordering: $DS"
    python AEEMU_Filtering_v2.py --filter-ordering --dataset "$DS" --folds $FOLDS
done

echo ""
echo "======================================================"
echo "  STEP FINAL: Generando figuras del paper"
echo "======================================================"
python generate_figures.py \
    --results-dir "$RESULTS_DIR" \
    --output-dir "$FIGURES_DIR"

echo ""
echo "✅ Todos los experimentos completados."
echo "   Figuras en: $FIGURES_DIR"
echo "   Resultados en: $RESULTS_DIR"