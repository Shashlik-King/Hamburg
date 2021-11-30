# -*- coding: utf-8 -*-
"""
Created on Sun Nov 28 19:45:08 2021

@author: SHAK
"""

from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
import mplcursors

image = Image.open('im.jpg')
data = np.array(image)
img = plt.imshow(data)

points = []

cursor = mplcursors.cursor(img, hover=False)
@cursor.connect("add")
def cursor_clicked(sel):
    # sel.annotation.set_visible(False)
    sel.annotation.set_text(
        f'Clicked on\nx: {sel.target[0]:.2f} y: {sel.target[1]:.2f}\nindex: {sel.target.index}')
    points.append(sel.target.index)
    print("Current list of points:", points)
    ## Draw line
    plt.plot(points[1],points[2])
    

plt.show()
print("Selected points:", points)



# class DrawLineWidget(object):
#     def __init__(self):
#         image = Image.open('im.jpg')
#         data = np.array(image)
#         img = plt.imshow(data)
#         # self.original_image = cv2.imread('im.jpg')
#         # self.original_image  = cv2.resize(self.original_image,[1000,1000], interpolation = cv2.INTER_LINEAR)
#         # self.original_image = cv2.resize(self.original_image,(700, 700))
#         # self.original_image  = cv2.resize(self.original_image,None,fx=1, fy=1, interpolation = cv2.INTER_CUBIC)
#         # self.clone = self.original_image.copy()

#         # plt.namedWindow('image')
#         # plt.setMouseCallback('image', self.extract_coordinates)

#         # List to store start/end points
#         self.image_coordinates = []

#     def extract_coordinates(self, event, x, y, flags, parameters):
#         # Record starting (x,y) coordinates on left mouse button click
#         if event == plt.EVENT_LBUTTONDOWN:
#             self.image_coordinates = [(x,y)]

#         # Record ending (x,y) coordintes on left mouse bottom release
#         elif event == plt.EVENT_LBUTTONUP:
#             self.image_coordinates.append((x,y))
#             print('Starting: {}, Ending: {}'.format(self.image_coordinates[0], self.image_coordinates[1]))

#             # Draw line
#             plt.line(self.clone, self.image_coordinates[0], self.image_coordinates[1], (0,250,10), 2)
#             plt.imshow("image", self.clone) 

#         # Clear drawing boxes on right mouse button click
#         elif event == plt.EVENT_RBUTTONDOWN:
#             self.clone = self.original_image.copy()

#     # def show_image(self):
#     #     return self.clone

# if __name__ == '__main__':
#     draw_line_widget = DrawLineWidget()
#     while True:
#         plt.imshow('image')
#         key = plt.waitKey(1)

#         # # Close program with keyboard 'q'
#         # if key == ord('c'):
#         #     plt.destroyAllWindows()
#         #     exit(1)
