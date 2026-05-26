from pipelines.product_pipeline import ProductPipeline


pipeline=(
    ProductPipeline()
)

pipeline.run()

# 만약 테스트시
# pipeline.run_test(
#     start=280,
#     limit=1
# )