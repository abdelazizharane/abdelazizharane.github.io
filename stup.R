pkgs<-c("knitr","rmarkdown","quarto")
missing<-pkgs[!pkgs %in% rownames(installed.packages())]
if(length(missing))install.packages(missing,repos="https://cloud.r-project.org")
cat("Done!\n")