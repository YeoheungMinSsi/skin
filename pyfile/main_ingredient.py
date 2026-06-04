from pipelines.ingredient_pipeline import IngredientPipeline


pipeline=(

    IngredientPipeline()

)


pipeline.run(
    start=2300,
    limit=100
)