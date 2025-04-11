import os
from ray.rllib.algorithms.ppo import PPOConfig
from ray import air, tune
import ray
import env

# Initialize Ray
ray.init()

# Define the PPO configuration
config = PPOConfig()
config = config.training(
    gamma=0.9, 
    lr=tune.grid_search([0.001]), 
    clip_param=0.2,
    train_batch_size=128
)

results_dir = os.path.abspath("./ray_results")

config = config.resources(num_gpus=0)
config = config.env_runners(num_env_runners=1)
config = config.environment(env="env.NetworkDefenseEnv")

# Use to_dict() to get the old-style python config dict when running with tune.
tune.Tuner(
    "PPO",
    run_config=air.RunConfig(stop={"training_iteration": 100},
                             storage_path=results_dir,
                             checkpoint_config=air.CheckpointConfig(
                                 checkpoint_at_end=True,
                                 checkpoint_frequency=10
                             )),
    param_space=config.to_dict(),
).fit()