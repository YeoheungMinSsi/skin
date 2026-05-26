from pipelines.ingredient_pipeline import IngredientPipeline


pipeline=(

    IngredientPipeline()

)


pipeline.run(
    start=400,
    limit=400
)