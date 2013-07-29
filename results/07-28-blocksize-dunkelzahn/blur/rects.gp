# Setup the output file.
set encoding utf8
set terminal pdfcairo
set output "rects-`echo $kern`.pdf"

# Set options for the figure.
set title "mmul execution time by local size"
set xlabel "X size"
set ylabel "Y size"
set xrange [-0.5:5.5]
set xtics ("1" 0, "2" 1, "4" 2, "8" 3, "16" 4, "32" 5)
set yrange [-0.5:5.5]
set ytics ("1" 0, "2" 1, "4" 2, "8" 3, "16" 4, "32" 5)

# For each thing to plot, set options then
# issue plot command.
#set palette grey
plot "rects-`echo $kern`.txt" matrix with image
