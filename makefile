slides.pdf: slides.md approximation_example.R partitioning_example.R
	pandoc -t beamer slides.md -o slides.pdf

approximation_example.Rout: approximation_example.R
	Rscript approximation_example.R > approximation_example.Rout

partitioning_example.Rout: approximation_example.Rout
	Rscript partitioning_example.R > partitioning_example.Rout
