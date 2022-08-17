require('dotenv').config()
const gulp = require('gulp')
const sass = require('gulp-sass')(require('sass'))
const svgSprite = require('gulp-svg-sprite')
const del = require('del')
const merge = require('merge-stream')
var fs = require('fs')
var path = require('path')
const { series } = require('gulp')

const staticIconPath = './static/icon'
const getFolders = dir => {
  return fs.readdirSync(dir).filter(function(file) {
    return fs.statSync(path.join(dir, file)).isDirectory()
  })
}

gulp.task('build-css', function() {
  return gulp
    .src(['styles/styles.scss'])
    .pipe(sass({ outputStyle: 'compressed' }).on('error', sass.logError))
    .pipe(gulp.dest('./static/styles/'))
})

// Watch task
gulp.task('watch', function() {
  gulp.watch('styles/**/*.scss', gulp.series('build-css'))
  // Other watchers
})

gulp.task('sprite:generate', function() {
  const iconDirs = getFolders(staticIconPath)

  const stepsArr = iconDirs.map(dir => {
    return gulp
      .src(`${dir}/*.svg`, { cwd: staticIconPath })
      .pipe(
        svgSprite({
          mode: {
            css: {
              render: {
                css: true
              },
              layout: 'vertical'
            }
          }
        })
      )
      .pipe(gulp.dest(`./${dir}`, { cwd: staticIconPath }))
  })

  return merge(stepsArr)
})

gulp.task('sprite:replace-url', function(done){
  const iconDirs = getFolders(staticIconPath)

  iconDirs.forEach((dir)=>{
    const cssFilePath = `${staticIconPath}/${dir}/css/sprite.css`
    fs.readFile(cssFilePath, 'utf-8', function (err, contents) {
      if (err) {
        console.log(err);
        return;
      }
      const searchRegex = /(?<=background: url\(")/g
      const replaceString = `/static/icon/${dir}/css/`
      const replaced = contents.replace(searchRegex, replaceString);

      fs.writeFile(cssFilePath, replaced, 'utf-8', function (err) {
        if (err) {
          console.log(err);
        }
      });
    });
  })

  done()
})

gulp.task('sprite:clean-up', function(done) {
  const iconDirs = getFolders(staticIconPath)

  iconDirs.forEach(async dir => {
    await del(`${staticIconPath}/${dir}/css`)
  })
  done()
})

gulp.task('sprite', series('sprite:clean-up', 'sprite:generate', 'sprite:replace-url'))
