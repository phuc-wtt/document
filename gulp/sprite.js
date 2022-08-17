function getFolders(dir) {
    return fs.readdirSync(dir)
      .filter(function(file) {
        return fs.statSync(path.join(dir, file)).isDirectory();
      });
}


gulp.task('sprite:generate', function (){
  const iconDirs = getFolders(staticIconPath)

  const stepsArr = iconDirs.map(dir => {
    return gulp.src(`${dir}/*.svg`, { cwd: staticIconPath })
      .pipe(svgSprite({
        mode: {
          css: { // activate the «css» mode
            render: {
              css: true // activate css output (with default options)
            }
          }
        }
      }))
      .pipe(gulp.dest(`./${dir}`, { cwd: staticIconPath }));
  })

  return merge(stepsArr)
})

gulp.task('sprite:clean', function(done) {
  const iconDirs = getFolders(staticIconPath)

  iconDirs.forEach(async (dir) => {
    await del(`${staticIconPath}/${dir}/css`) // clean up generated sprite first
  })
  done()
})

gulp.task('sprite', series('sprite:clean', 'sprite:generate'))
