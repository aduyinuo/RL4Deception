from ray.rllib.algorithms.ppo import PPOConfig
from env import NetworkDefenseEnv

# Define the path to the checkpoint
checkpoint_path = "./ray_results/{}"

# Initialize the PPO configuration
config = PPOConfig()
config = config.environment(env="custom_gym_env.NetworkDefenseEnv")

# Build the algorithm from the configuration
algo = config.build()

# Restore the algorithm from the checkpoint
algo.restore(checkpoint_path)

# Evaluate or use the trained model
env = NetworkDefenseEnv()
obs = env.reset()
done = False
total_reward = 0

while not done:
    action = algo.compute_single_action(obs)
    obs, reward, done, info = env.step(action)
    total_reward += reward

print("Total reward:", total_reward)
