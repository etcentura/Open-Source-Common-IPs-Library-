from PIL import Image
import numpy as np
import argparse
import os

# Parser to get arguments
parser = argparse.ArgumentParser()
parser.add_argument("file_path", type=str, help="Path to the file to be parsed")
parser.add_argument("width", type=int, help="Width of the image to be parsed")
parser.add_argument("height", type=int, help="Height of the image to be parsed")
parser.add_argument("pix_width", type=int, help="Number of pixels used to represent one pixel")
parser.add_argument("dump_path", type=str, help="Dump file path")

# Argument parsing with the parser
args = parser.parse_args()
parsed_file_path = args.file_path
parsed_width = args.width
parsed_height = args.height
parsed_pix_width = args.pix_width
parsed_dump_path = args.dump_path

print("parsed_file_path is {}".format(parsed_file_path))
print("parsed_width is {}".format(parsed_width))
print("parsed_height is {}".format(parsed_height))
print("parsed_pix_width is {}".format(parsed_pix_width))
print("parsed_dump_path is {}".format(parsed_dump_path))

if (parsed_pix_width != 8):
    print("Only 8 bits per pixel allowed right now. WIP")
else:
    # Opening data file
    with open(parsed_file_path, "rb") as f:
        data = f.read()

    # Getting pixes
    pixels = np.frombuffer(data, dtype=np.uint8)

    # Checking whether the number of pixels and the size are equal
    if len(pixels) != parsed_width * parsed_height:
        print(f"Warning: data size ({len(pixels)}) is not equal {parsed_width}x{parsed_height}")

    # Forming an image (L - one color component for the image)
    image = Image.fromarray(pixels.reshape((parsed_height, parsed_width)), mode="L")

    # Create directory if it doesn't exist
    output_dir = os.path.dirname(parsed_dump_path)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"Created directory: {output_dir}")

    # Saving image as an png image
    output_path = parsed_dump_path
    image.save(output_path)
    print(f"Image saved to {output_path}")
