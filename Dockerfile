FROM debian:latest
RUN apt-get update && apt-get install -y ca-certificates libgcc1 libssl3 libstdc++6 zlib1g libicu-dev libgdiplus
COPY MealPlannerApi/* /opt/MealPlannerApi/
WORKDIR /opt/MealPlannerApi
RUN chmod +x ./MealPlannerApi
EXPOSE 8080
ENTRYPOINT ["./MealPlannerApi"]