import os

from selenium import webdriver
from PIL import Image
from time import sleep
from datetime import datetime
from selenium.webdriver.chrome.options import Options

from portfoliofy import get_screenshot, get_screenshot_resized, get_screenshot_resized_overlaid


# Test if screenshot has correct aspect ratio and by extension test
# if url is reacable and a screenshot was taken
def test_get_screenshot():

    # Set directory_path
    now = datetime.now()
    directory = now.strftime('%y%m%d_%H%M%S_%f')[:-3]
    directory_path = f"output/{directory}_test1"
    os.makedirs(directory_path)

    # Set remote_url
    remote_url = "https://cs50.harvard.edu/python/2022/"

    # Set wait
    wait = 2

    # Set large_width and large_height
    large_width = 1440
    large_height = 900
    aspect_ratio = round(1440 / 900, 3)

    # Set file_name_large
    file_name_large = "test_get_screenshot.png"

    # Call function to be tested
    get_screenshot(remote_url, wait, large_width, large_height, directory_path, file_name_large)

    # Test
    test_screenshot = Image.open(f"{directory_path}/{file_name_large}")
    width, height = test_screenshot.size

    assert aspect_ratio == round(width / height, 3)


# Test if an image is resized
def test_get_screenshot_resized():

    # Set directory_path
    now = datetime.now()
    directory = now.strftime('%y%m%d_%H%M%S_%f')[:-3]
    directory_path = f"output/{directory}_test2"
    os.makedirs(directory_path)

    # Set variables
    test_file_name = f"test_image.png"
    test_new_file_name = f"test_image_resized.png"
    test_new_width = 1280
    test_height_crop = 720

    # Create new image to resize
    test_image_new = Image.new("RGB", (1440, 900), "yellow")
    test_image_new.save(f"{directory_path}/{test_file_name}")

    get_screenshot_resized(directory_path, test_file_name, test_new_file_name, test_new_width, test_height_crop)

    # Test
    test_image_resized = Image.open(f"{directory_path}/{test_new_file_name}")

    assert test_image_resized.size == (test_new_width, test_height_crop)


# Test if image is inserted on base image within border by checking if border color is expected color
def test_get_screenshot_resized_overlaid():

    # Set directory_path
    now = datetime.now()
    directory = now.strftime('%y%m%d_%H%M%S_%f')[:-3]
    directory_path = f"output/{directory}_test3"
    os.makedirs(directory_path)

    # Set variables
    test_image_base = "output/devices_desktop.png"
    test_image_overlay = f"{directory_path}/test_image_overlay.png"
    test_image_output = f"test_image_output.png"
    lat = 628
    lng = 625

    # Create a new image with a yellow background
    test_image_new = Image.new("RGB", (2048, 1152), "yellow")
    test_image_new.save(f"{test_image_overlay}")

    # Call function to be tested
    get_screenshot_resized_overlaid(test_image_base, test_image_overlay, lat, lng, directory_path, test_image_output)

    # Test
    expected_color = (35, 68, 93, 255)

    image = Image.open(f"{directory_path}/{test_image_output}")

    color_top_left = image.getpixel((627, 625))
    color_top_right = image.getpixel((2676, 624))
    color_bottom_left = image.getpixel((678, 1778))
    color_bottom_right = image.getpixel((2677, 1777))

    assert color_top_left == expected_color, f"Pixel color at top left is not {expected_color}"
    assert color_top_right == expected_color, f"Pixel color at top right is not {expected_color}"
    assert color_bottom_left == expected_color, f"Pixel color at bottom left is not {expected_color}"
    assert color_bottom_right == expected_color, f"Pixel color at bottom right is not {expected_color}"