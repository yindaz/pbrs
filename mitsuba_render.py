import mitsuba
from mitsuba.core import *
from mitsuba.render import SceneHandler
import os
from mitsuba.render import RenderQueue, RenderJob
import multiprocessing
import numpy as np
import sys, getopt



def main(argv):
	scene_xml_name  = ''
	camera_txt_name = ''
	output_folder   = ''
	camera_indicate_name = ''

	# Read command line args
	opts, args = getopt.getopt(argv,"s:c:o:h:g:")
	for opt, arg in opts:
		if opt == '-h':
			print 'mitsuba_render.py -s <scene_xml> -c <camera_file> -g <good_camera_indicator_file> -o <output_directory>'
			sys.exit()
		elif opt in ("-s", "--scenefile"):
			scene_xml_name = arg
		elif opt in ("-c", "--camerafile"):
			camera_txt_name = arg
		elif opt in ("-o", "--outputdir"):
			output_folder = arg
		elif opt in ("-g", "--goodcamerafile"):
			camera_indicate_name = arg

	print('Render job for %s starts...\n' % scene_xml_name)

	if not os.path.exists(output_folder):
		os.makedirs(output_folder)
	camera = np.loadtxt(camera_txt_name)
	goodcam = np.loadtxt(camera_indicate_name)

	last_dest = output_folder + '%06i_mlt.png' % (len(camera)-1)
	if os.path.isfile(last_dest):
		print('Job is done in the first round.\n')
		return
	

	tmp = scene_xml_name.split('/')
	work_path = '/'.join(tmp[0:-1])

	os.chdir(work_path)

	paramMap = StringMap()
	paramMap['emitter_scale'] = '75'
	paramMap['fov'] = '63.414969'
	paramMap['origin'] = '0 0 0'
	paramMap['target'] = '1 1 1'
	paramMap['up'] = '1 0 0'
	paramMap['sampler'] = '1024'
	paramMap['width'] = '640'
	paramMap['height'] = '480'
	paramMap['envmap_path'] = './util_data/HDR_111_Parking_Lot_2_Ref.hdr'
	paramMap['default_texture_path'] = './util_data/wallp_0.jpg'

	fileResolver = Thread.getThread().getFileResolver()
	scene = SceneHandler.loadScene(fileResolver.resolve(scene_xml_name), paramMap)

	scheduler = Scheduler.getInstance()
	# Start up the scheduling system with one worker per local core
	for i in range(0, multiprocessing.cpu_count()):
		scheduler.registerWorker(LocalWorker(i, 'wrk%i' % i))
	scheduler.start()
	# Create a queue for tracking render jobs
	queue = RenderQueue()

	from mitsuba.render import Scene
	sensor = scene.getSensor()
	scene.initialize()

	for i in range(0,len(camera)):
		if goodcam[i]<0.5:
			continue

		destination = output_folder + '%06i_mlt' % i
		if os.path.isfile(destination+'.rgbe'):
			continue

		c = camera[i]
		t = Transform.lookAt(Point(c[0],c[1],c[2]),Point(c[0]+c[3],c[1]+c[4],c[2]+c[5]),Vector(c[6],c[7],c[8]))
		sensor.setWorldTransform(t)
		scene.setDestinationFile(destination)

		# # Create a render job and insert it into the queue. Note how the resource
		# # ID of the original scene is provided to avoid sending the full scene
		# # contents over the network multiple times.
		job = RenderJob('myRenderJob' + str(i), scene, queue)
		job.start()
		queue.waitLeft(0)

	print('%d render jobs finished!\n' % len(camera))

if __name__ == "__main__":
   main(sys.argv[1:])
