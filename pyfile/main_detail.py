from pipelines.detail_pipeline import DetailPipeline


pipeline = DetailPipeline()

# pipeline.run(
#     limit=10
# )


pipeline.run(
    start=8808,
    limit=1
)