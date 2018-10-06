library(iSEE)
library(shiny)
library(RColorBrewer)

# Load the object ----

# It contains:
# - microarray raw expression data
# - probe information in featureData slot
# fvarLabels(eset)
# - sample information in phenoData slot
# varLabels(eset)
sce <- readRDS("iSEE_GSE93776/GSE93776_sce.rds")

# Remove certain feature metadata column overloaded with information
allFeatureMetadataColumns <- c("ID", "GB_ACC", "SPOT_ID", "Species.Scientific.Name", "Annotation.Date",  "Sequence.Type", "Sequence.Source", "Target.Description", "Representative.Public.ID",  "Gene.Title", "Gene.Symbol", "ENTREZ_GENE_ID", "RefSeq.Transcript.ID",  "Gene.Ontology.Biological.Process", "Gene.Ontology.Cellular.Component",  "Gene.Ontology.Molecular.Function")

selectedFeatureMetadataColumns <- c("Gene.Symbol", "ENTREZ_GENE_ID", "GB_ACC", "SPOT_ID", "Sequence.Source", "Target.Description")

rowData(sce) <- rowData(sce)[, selectedFeatureMetadataColumns]


# Prepare iSEE panel layout ----

initialPanels <- DataFrame(
    Name=c("Feature assay plot 1", "Row statistics table 1"),
    Width=c(12, 12),
    Height=c(600, 500)
)

# Prepare the individual panel settings ----

featAssayArgs <- featAssayPlotDefaults(sce, 1)
featAssayArgs$XAxis <- "Column data"
featAssayArgs$XAxisColData <- "cell.type.ch1"
featAssayArgs$YAxisRowTable <- "Row statistics table 1"
featAssayArgs$ColorBy <- "Column data"
featAssayArgs$ColorByColData <- "disease.ch1"
featAssayArgs$PointSize <- 3
featAssayArgs$PointAlpha <- 0.5
featAssayArgs$FontSize <- 1.5

rowStatArgs <- rowStatTableDefaults(sce, 1)
rowStatArgs$Selected <- match("CD3E", rowData(sce)[["Gene.Symbol"]])
# Note, the following form should be used for tables that have a large number of entries,
# where filtering fields do not behave as selectize inputs
rowStatArgs$SearchColumns <- list("Gene.Symbol"='(^CD3E$|IL12B|KLRF1|CD79A)')
# The following form should be used for smaller tables,
# where filtering fields behave as selectize inputs
# rowStatArgs$SearchColumns <- list("Gene.Symbol"='["CD3E","IL1B","KLRF1","CD79A"]')

# Prepare an ExperimentColorMap ----

cm_disease <- function(n) {
    x <- brewer.pal(3, "Set1")[c(3, 1)]
    names(x) <- levels(sce$disease)
    x
}

ecm <- ExperimentColorMap(
    colData=list(
        disease=cm_disease
    )
)

# Import the tour steps ----

tour <- read.delim("iSEE_GSE93776/tour_steps.txt", sep=";", quote="")

# Build the app ----

app <- iSEE(
    se=sce,
    featAssayArgs=featAssayArgs, rowStatArgs=rowStatArgs,
    redDimMax=0, colDataMax=1, featAssayMax=1, rowStatMax=1,
    rowDataMax=1, heatMapMax=1,
    initialPanels=initialPanels,
    colormap=ecm, tour=tour,
    appTitle="GSE93776 | Immune cells from rheumatoid arthritis and healthy donors")

# Launch the app

# e.g. each app can be assigned a port
runApp(app, port=3664)
